package com.fusion.module.ai.framework.ai.core.model.dashscope;

import com.fusion.module.ai.enums.model.AiPlatformEnum;
import com.fusion.module.ai.framework.ai.core.model.AiModelFactoryImpl;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ai.embedding.EmbeddingModel;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 通义千问「文本嵌入」走 <b>OpenAI 兼容端点</b>的 mock 回归测试
 *
 * <h3>为什么要有它</h3>
 * 知识库的向量化原本走 {@code DashScopeEmbeddingModel}，但它调用了 Spring AI 2.0.0
 * 已删除的 {@code ModelOptionsUtils.copyToTarget}，一调用就抛 {@code NoSuchMethodError}。
 * 修复方式是把通义千问的嵌入改走 DashScope 的 OpenAI 兼容端点
 * （{@code /compatible-mode/v1/embeddings}，已直连实测该路径存在）。
 *
 * 本测试<b>走生产代码路径</b>（{@link AiModelFactoryImpl#getOrCreateEmbeddingModel}），
 * 用本地假上游钉死三件事：
 * <ol>
 *   <li>请求确实发到了配置的 {@code baseUrl}（而不是 api.openai.com）；</li>
 *   <li>请求里带上了 model 与 input；</li>
 *   <li>OpenAI 形状的响应能被正确解析成向量。</li>
 * </ol>
 * 第 1 条尤其关键：Spring AI 2.0 的 OpenAI 集成走的是官方 {@code com.openai} SDK，
 * 如果它不认 options 里的 baseUrl，那么「改走兼容端点」这个修复本身就是无效的。
 *
 * @author fansili
 */
public class TongYiEmbeddingModelMockTest {

    private HttpServer server;

    private String baseUrl;

    private final AtomicReference<String> requestPath = new AtomicReference<>();

    private final AtomicReference<String> requestBody = new AtomicReference<>();

    private final AtomicReference<String> authHeader = new AtomicReference<>();

    @BeforeEach
    public void setUp() throws IOException {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        // Spring AI 的 OpenAI 客户端会在 baseUrl 后拼 /embeddings
        server.createContext("/v1/embeddings", this::handleEmbeddings);
        server.start();
        baseUrl = "http://127.0.0.1:" + server.getAddress().getPort() + "/v1";
    }

    @AfterEach
    public void tearDown() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    public void testEmbed_whenTongYiPlatform() {
        // 准备：走生产代码路径创建 EmbeddingModel
        EmbeddingModel embeddingModel = new AiModelFactoryImpl().getOrCreateEmbeddingModel(
                AiPlatformEnum.TONG_YI, "sk-mock-key", baseUrl, "text-embedding-v4");

        // 调用
        float[] vector = embeddingModel.embed("你好，世界");

        // 断言 1：请求打到了 mock 上游（说明 baseUrl 生效，没跑到 api.openai.com）
        assertEquals("/v1/embeddings", requestPath.get(), "嵌入请求没有发到配置的 baseUrl");

        // 断言 2：请求体带上了模型名与文本
        String body = requestBody.get();
        assertNotNull(body);
        assertTrue(body.contains("text-embedding-v4"), "请求体缺少 model：" + body);
        assertTrue(body.contains("你好，世界"), "请求体缺少 input：" + body);
        assertFalse(body.contains("null"), "请求体不应包含 null 字段：" + body);

        // 断言 3：鉴权头正确
        assertEquals("Bearer sk-mock-key", authHeader.get());

        // 断言 4：响应被解析成向量
        assertArrayEquals(new float[]{0.1f, 0.2f, 0.3f}, vector, 1e-6f);
    }

    private void handleEmbeddings(HttpExchange exchange) throws IOException {
        requestPath.set(exchange.getRequestURI().getPath());
        authHeader.set(exchange.getRequestHeaders().getFirst("Authorization"));
        try (InputStream in = exchange.getRequestBody()) {
            requestBody.set(new String(in.readAllBytes(), StandardCharsets.UTF_8));
        }
        // OpenAI 兼容形状的响应（DashScope 兼容端点返回的也是这个形状）
        String json = "{\"object\":\"list\",\"data\":[{\"object\":\"embedding\",\"index\":0,"
                + "\"embedding\":[0.1,0.2,0.3]}],\"model\":\"text-embedding-v4\","
                + "\"usage\":{\"prompt_tokens\":4,\"total_tokens\":4}}";
        byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json; charset=utf-8");
        exchange.sendResponseHeaders(200, bytes.length);
        try (var out = exchange.getResponseBody()) {
            out.write(bytes);
        }
    }

}
