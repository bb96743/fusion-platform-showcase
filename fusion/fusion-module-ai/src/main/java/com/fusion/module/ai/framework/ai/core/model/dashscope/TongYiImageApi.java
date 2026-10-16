package com.fusion.module.ai.framework.ai.core.model.dashscope;

import cn.hutool.core.util.StrUtil;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.Assert;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import java.util.List;

/**
 * 通义千问（DashScope 原生协议）的<b>文生图</b> HTTP API
 *
 * 官方接口是「异步两步」协议，所以本类比普通 REST 客户端多一层任务语义：
 * <ol>
 *   <li>创建任务：{@code POST /api/v1/services/aigc/text2image/image-synthesis}
 *       （必须带请求头 {@code X-DashScope-Async: enable}），返回 {@code task_id}；</li>
 *   <li>轮询结果：{@code GET /api/v1/tasks/{task_id}}，直到 {@code task_status} 不再是 PENDING / RUNNING。</li>
 * </ol>
 *
 * {@code task_id} 与结果 {@code url} 都只有 <b>24 小时</b>有效期，所以拿到 url 必须立刻下载落库。
 *
 * @see <a href="https://help.aliyun.com/zh/model-studio/first-call-to-image-and-video-api">使用 Postman 或 cURL 调用图像/视频生成 API</a>
 * @author fansili
 */
public class TongYiImageApi {

    /**
     * 北京地域的默认服务地址（与 OpenAI 兼容端点同域，但协议路径不同）
     */
    public static final String DEFAULT_BASE_URL = "https://dashscope.aliyuncs.com";

    public static final String PROVIDER_NAME = "TongYi";

    /**
     * 兼容端点后缀：库里「API 密钥」的 url 字段若被填成兼容端点地址，
     * 不能直接拿来拼原生路径，这里做一次归一化。
     */
    private static final String COMPATIBLE_MODE_SUFFIX = "/compatible-mode/v1";

    private static final String IMAGE_SYNTHESIS_PATH = "api/v1/services/aigc/text2image/image-synthesis";

    private static final String TASK_PATH = "api/v1/tasks/{taskId}";

    /**
     * 异步调用开关：缺少该请求头时服务端会报「current user api does not support synchronous calls」
     */
    private static final String ASYNC_ENABLE_HEADER = "X-DashScope-Async";

    private final RestClient restClient;

    public TongYiImageApi(String apiKey) {
        this(null, apiKey, RestClient.builder());
    }

    public TongYiImageApi(String baseUrl, String apiKey) {
        this(baseUrl, apiKey, RestClient.builder());
    }

    public TongYiImageApi(String baseUrl, String apiKey, RestClient.Builder restClientBuilder) {
        Assert.hasText(apiKey, "通义千问（DashScope）的 API Key 不能为空");
        this.restClient = restClientBuilder
                .baseUrl(normalizeBaseUrl(baseUrl))
                .defaultHeaders(headers -> {
                    headers.setBearerAuth(apiKey);
                    headers.setContentType(MediaType.APPLICATION_JSON);
                })
                .build();
    }

    /**
     * 把库里的 url 归一化成原生协议的 baseUrl
     */
    static String normalizeBaseUrl(String baseUrl) {
        String result = StrUtil.blankToDefault(baseUrl, DEFAULT_BASE_URL).trim();
        if (result.endsWith(COMPATIBLE_MODE_SUFFIX)) {
            result = result.substring(0, result.length() - COMPATIBLE_MODE_SUFFIX.length());
        }
        return StrUtil.removeSuffix(result, "/");
    }

    /**
     * 第一步：创建文生图任务
     *
     * @return 包含 task_id 的响应
     */
    public TaskSubmitResponse submit(ImageSynthesisRequest request) {
        Assert.notNull(request, "文生图请求不能为空");
        Assert.hasText(request.input() != null ? request.input().prompt() : null, "提示词不能为空");
        try {
            ResponseEntity<TaskSubmitResponse> entity = this.restClient.post()
                    .uri(IMAGE_SYNTHESIS_PATH)
                    .header(ASYNC_ENABLE_HEADER, "enable")
                    .body(request)
                    .retrieve()
                    .toEntity(TaskSubmitResponse.class);
            Assert.notNull(entity.getBody(), "通义千问 文生图 创建任务返回空响应");
            return entity.getBody();
        } catch (RestClientResponseException ex) {
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 创建任务失败：HTTP {} {}",
                    ex.getStatusCode().value(), ex.getResponseBodyAsString()), ex);
        }
    }

    /**
     * 第二步：按 task_id 查询任务结果
     */
    public TaskResponse getTask(String taskId) {
        Assert.hasText(taskId, "taskId 不能为空");
        try {
            ResponseEntity<TaskResponse> entity = this.restClient.get()
                    .uri(TASK_PATH, taskId)
                    .retrieve()
                    .toEntity(TaskResponse.class);
            Assert.notNull(entity.getBody(), "通义千问 文生图 查询任务返回空响应");
            return entity.getBody();
        } catch (RestClientResponseException ex) {
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 查询任务({})失败：HTTP {} {}",
                    taskId, ex.getStatusCode().value(), ex.getResponseBodyAsString()), ex);
        }
    }

    // ========== 请求 / 响应体 ==========

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ImageSynthesisRequest(@JsonProperty("model") String model,
                                        @JsonProperty("input") Input input,
                                        @JsonProperty("parameters") Parameters parameters) {

        @JsonInclude(JsonInclude.Include.NON_NULL)
        public record Input(@JsonProperty("prompt") String prompt) {
        }

        @JsonInclude(JsonInclude.Include.NON_NULL)
        public record Parameters(@JsonProperty("size") String size,
                                 @JsonProperty("n") Integer n,
                                 @JsonProperty("negative_prompt") String negativePrompt,
                                 @JsonProperty("prompt_extend") Boolean promptExtend,
                                 @JsonProperty("watermark") Boolean watermark,
                                 @JsonProperty("seed") Integer seed) {
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record TaskSubmitResponse(@JsonProperty("request_id") String requestId,
                                     @JsonProperty("output") TaskSubmitOutput output,
                                     @JsonProperty("code") String code,
                                     @JsonProperty("message") String message) {

        @JsonIgnoreProperties(ignoreUnknown = true)
        public record TaskSubmitOutput(@JsonProperty("task_id") String taskId,
                                       @JsonProperty("task_status") String taskStatus) {
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record TaskResponse(@JsonProperty("request_id") String requestId,
                               @JsonProperty("output") TaskOutput output,
                               @JsonProperty("usage") Usage usage,
                               @JsonProperty("code") String code,
                               @JsonProperty("message") String message) {

        @JsonIgnoreProperties(ignoreUnknown = true)
        public record TaskOutput(@JsonProperty("task_id") String taskId,
                                 @JsonProperty("task_status") String taskStatus,
                                 @JsonProperty("results") List<Result> results,
                                 @JsonProperty("code") String code,
                                 @JsonProperty("message") String message) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        public record Result(@JsonProperty("orig_prompt") String origPrompt,
                             @JsonProperty("actual_prompt") String actualPrompt,
                             @JsonProperty("url") String url) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        public record Usage(@JsonProperty("image_count") Integer imageCount,
                            @JsonProperty("size") String size) {
        }
    }

}
