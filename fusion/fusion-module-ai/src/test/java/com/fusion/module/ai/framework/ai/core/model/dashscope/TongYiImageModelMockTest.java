package com.fusion.module.ai.framework.ai.core.model.dashscope;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import io.micrometer.observation.ObservationRegistry;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ai.image.ImagePrompt;
import org.springframework.ai.image.ImageResponse;
import org.springframework.ai.retry.RetryUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.*;

/**
 * {@link TongYiImageModel} 的本地 mock 回归测试
 *
 * <h3>为什么要有它</h3>
 * DashScope 文生图是「创建任务 → 轮询结果」两步异步协议，而自研客户端正是为了绕开
 * spring-ai-alibaba 与 Spring AI 2.0.0 的不兼容（见 {@link TongYiImageModel} 类说明）。
 * 真实链路需要可用的（未欠费的）通义千问账号，所以这里用 JDK 自带的
 * {@link HttpServer} 起一个假的上游，把<b>协议形状</b>钉死：
 * 请求头、请求体、轮询行为、成功 / 失败两条分支的解析。
 *
 * 一旦将来有人误把「原生协议」换成别的实现，这个测试会立刻失败。
 *
 * @author fansili
 */
public class TongYiImageModelMockTest {

    private HttpServer server;

    private String baseUrl;

    /** 记录收到的请求：路径 -> 次数 */
    private final Map<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();

    /** 创建任务时收到的请求体 */
    private final AtomicReference<String> submitBody = new AtomicReference<>();

    /** 创建任务时收到的请求头 */
    private final AtomicReference<Map<String, List<String>>> submitHeaders = new AtomicReference<>();

    /** 查询任务时的 Authorization 头 */
    private final AtomicReference<String> taskAuthHeader = new AtomicReference<>();

    /** 轮询第几次才返回成功（模拟「前几次还在跑」） */
    private final AtomicInteger successAfterPolls = new AtomicInteger(2);

    /** 让任务直接失败 */
    private volatile boolean taskFails = false;

    @BeforeEach
    public void setUp() throws IOException {
        // 端口置 0 由系统分配，避免与本机其它服务冲突
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/api/v1/services/aigc/text2image/image-synthesis", this::handleSubmit);
        server.createContext("/api/v1/tasks/", this::handleTask);
        server.start();
        baseUrl = "http://127.0.0.1:" + server.getAddress().getPort();
    }

    @AfterEach
    public void tearDown() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    public void testCall_whenTaskSucceeded() {
        // 准备：第 2 次轮询才成功
        successAfterPolls.set(2);

        // 调用
        TongYiImageModel imageModel = newModel();
        ImageResponse response = imageModel.call(new ImagePrompt("一只在窗台上的橘猫",
                TongYiImageOptions.builder().model("wan2.6-t2i").n(1).width(1024).height(1024).build()));

        // 断言 1：结果 url 被正确解析
        assertNotNull(response.getResult());
        assertEquals("http://127.0.0.1/mock/1.png", response.getResult().getOutput().getUrl());

        // 断言 2：创建任务的请求头必须带异步开关，且带 Bearer 鉴权
        Map<String, List<String>> headers = submitHeaders.get();
        assertNotNull(headers);
        assertEquals(List.of("enable"), headers.get("X-Dashscope-Async"));
        assertEquals(List.of("Bearer sk-mock-key"), headers.get("Authorization"));

        // 断言 3：创建任务的请求体符合 DashScope 原生协议
        String body = submitBody.get();
        assertNotNull(body);
        assertTrue(body.contains("\"model\":\"wan2.6-t2i\""), "请求体缺少 model：" + body);
        assertTrue(body.contains("\"prompt\":\"一只在窗台上的橘猫\""), "请求体缺少 prompt：" + body);
        assertTrue(body.contains("\"size\":\"1024*1024\""), "请求体缺少 size：" + body);
        assertTrue(body.contains("\"n\":1"), "请求体缺少 n：" + body);

        // 断言 4：确实轮询了 2 次（第 1 次 RUNNING、第 2 次 SUCCEEDED），且查询带鉴权
        assertEquals(2, requestCounts.get("/api/v1/tasks/task-1").get());
        assertEquals("Bearer sk-mock-key", taskAuthHeader.get());
    }

    @Test
    public void testCall_whenTaskFailed() {
        taskFails = true;

        TongYiImageModel imageModel = newModel();
        IllegalStateException ex = assertThrows(IllegalStateException.class,
                () -> imageModel.call(new ImagePrompt("一只猫", TongYiImageOptions.builder().build())));

        // 失败时必须把上游的 code / message 带出来，否则排查只能靠猜
        assertTrue(ex.getMessage().contains("InvalidParameter"), ex.getMessage());
        assertTrue(ex.getMessage().contains("num_images_per_prompt must be 1"), ex.getMessage());
    }

    @Test
    public void testNormalizeBaseUrl() {
        // 用户可能把「兼容端点」地址填进库里，原生路径不能直接拼在它后面
        assertEquals("https://dashscope.aliyuncs.com",
                TongYiImageApi.normalizeBaseUrl("https://dashscope.aliyuncs.com/compatible-mode/v1"));
        assertEquals("https://dashscope.aliyuncs.com",
                TongYiImageApi.normalizeBaseUrl("https://dashscope.aliyuncs.com/"));
        assertEquals("https://dashscope.aliyuncs.com", TongYiImageApi.normalizeBaseUrl(null));
        assertEquals("https://dashscope.aliyuncs.com", TongYiImageApi.normalizeBaseUrl("  "));
    }

    // ========== 辅助方法 ==========

    private TongYiImageModel newModel() {
        // 轮询间隔压到 20ms，让测试跑得快
        return new TongYiImageModel(new TongYiImageApi(baseUrl, "sk-mock-key"),
                TongYiImageOptions.builder().build(), RetryUtils.DEFAULT_RETRY_TEMPLATE,
                ObservationRegistry.NOOP, 20L, 5_000L);
    }

    private void handleSubmit(HttpExchange exchange) throws IOException {
        requestCounts.computeIfAbsent(exchange.getRequestURI().getPath(), k -> new AtomicInteger()).incrementAndGet();
        submitHeaders.set(exchange.getRequestHeaders());
        submitBody.set(readBody(exchange));
        writeJson(exchange, 200,
                "{\"request_id\":\"req-1\",\"output\":{\"task_id\":\"task-1\",\"task_status\":\"PENDING\"}}");
    }

    private void handleTask(HttpExchange exchange) throws IOException {
        requestCounts.computeIfAbsent(exchange.getRequestURI().getPath(), k -> new AtomicInteger()).incrementAndGet();
        taskAuthHeader.set(exchange.getRequestHeaders().getFirst("Authorization"));
        if (taskFails) {
            writeJson(exchange, 200, "{\"request_id\":\"req-2\",\"output\":{\"task_id\":\"task-1\","
                    + "\"task_status\":\"FAILED\",\"code\":\"InvalidParameter\","
                    + "\"message\":\"num_images_per_prompt must be 1\"}}");
            return;
        }
        // 前 (successAfterPolls - 1) 次返回 RUNNING
        if (requestCounts.get(exchange.getRequestURI().getPath()).get() < successAfterPolls.get()) {
            writeJson(exchange, 200, "{\"request_id\":\"req-2\",\"output\":"
                    + "{\"task_id\":\"task-1\",\"task_status\":\"RUNNING\"}}");
            return;
        }
        writeJson(exchange, 200, "{\"request_id\":\"req-3\",\"output\":{\"task_id\":\"task-1\","
                + "\"task_status\":\"SUCCEEDED\",\"results\":[{\"orig_prompt\":\"一只在窗台上的橘猫\","
                + "\"actual_prompt\":\"一只橘猫\",\"url\":\"http://127.0.0.1/mock/1.png\"}],"
                + "\"task_metrics\":{\"TOTAL\":1,\"SUCCEEDED\":1,\"FAILED\":0}},"
                + "\"usage\":{\"image_count\":1,\"size\":\"1024*1024\"}}");
    }

    private static String readBody(HttpExchange exchange) throws IOException {
        try (InputStream in = exchange.getRequestBody()) {
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    private static void writeJson(HttpExchange exchange, int status, String json) throws IOException {
        byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json; charset=utf-8");
        exchange.sendResponseHeaders(status, bytes.length);
        try (var out = exchange.getResponseBody()) {
            out.write(bytes);
        }
    }

}
