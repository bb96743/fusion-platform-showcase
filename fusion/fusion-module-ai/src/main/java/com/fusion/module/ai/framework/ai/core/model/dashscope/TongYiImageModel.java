package com.fusion.module.ai.framework.ai.core.model.dashscope;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import io.micrometer.observation.ObservationRegistry;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.image.Image;
import org.springframework.ai.image.ImageGeneration;
import org.springframework.ai.image.ImageModel;
import org.springframework.ai.image.ImageOptions;
import org.springframework.ai.image.ImagePrompt;
import org.springframework.ai.image.ImageResponse;
import org.springframework.ai.image.observation.DefaultImageModelObservationConvention;
import org.springframework.ai.image.observation.ImageModelObservationContext;
import org.springframework.ai.image.observation.ImageModelObservationConvention;
import org.springframework.ai.image.observation.ImageModelObservationDocumentation;
import org.springframework.ai.model.ModelOptionsUtils;
import org.springframework.ai.retry.RetryUtils;
import org.springframework.core.retry.RetryTemplate;
import org.jspecify.annotations.Nullable;
import org.springframework.util.Assert;

import java.util.ArrayList;
import java.util.List;

/**
 * 通义千问（DashScope 原生协议）的 {@link ImageModel} 实现
 *
 * <h3>为什么自己实现，而不是用 spring-ai-alibaba 的 DashScopeImageModel</h3>
 * {@code DashScopeImageModel} 内部调用了 {@code ModelOptionsUtils.copyToTarget(...)} 与
 * {@code ModelOptionsUtils.merge(...)}，而 Spring AI <b>2.0.0</b> 的 {@code ModelOptionsUtils}
 * 只剩 {@code mergeOption} 一个方法（已用 {@code javap} 逐类核对），
 * 因此一旦调用必然抛 {@code NoSuchMethodError}。文生图比对话还多坏一个方法。
 * 上游 {@code spring-ai-alibaba-dashscope} 至今（Maven Central 最新 2.0.0-M1.1）没有与 Spring AI 2.0.0 对齐的版本。
 *
 * <h3>协议</h3>
 * DashScope 文生图是<b>异步两步</b>协议（见 {@link TongYiImageApi}）：
 * 创建任务拿到 {@code task_id} 后，需要轮询查询接口直到 {@code task_status} 变为终态。
 * 本类把这两步封装成一次同步的 {@link #call(ImagePrompt)} —— 调用方
 * （{@code AiImageServiceImpl#executeDrawImage}）本身就跑在 {@code @Async} 线程里，
 * 这里阻塞等待不会占用请求线程。
 *
 * @author fansili
 */
public class TongYiImageModel implements ImageModel {

    private static final Logger logger = LoggerFactory.getLogger(TongYiImageModel.class);

    private static final ImageModelObservationConvention DEFAULT_OBSERVATION_CONVENTION =
            new DefaultImageModelObservationConvention();

    /**
     * 未指定模型时的兜底值：通义万相-文生图 V2（官方推荐用于纯文本生图）
     */
    public static final String DEFAULT_IMAGE_MODEL = "wan2.6-t2i";

    /** 任务终态 */
    private static final String STATUS_SUCCEEDED = "SUCCEEDED";
    private static final String STATUS_FAILED = "FAILED";
    private static final String STATUS_CANCELED = "CANCELED";
    private static final String STATUS_UNKNOWN = "UNKNOWN";

    /** 轮询间隔：官方建议 3~5 秒 */
    private static final long DEFAULT_POLL_INTERVAL_MILLIS = 3_000L;

    /** 轮询总超时：官方说明耗时「十几秒到数分钟」，这里给 3 分钟 */
    private static final long DEFAULT_TIMEOUT_MILLIS = 180_000L;

    private final TongYiImageApi imageApi;

    private final TongYiImageOptions defaultOptions;

    private final RetryTemplate retryTemplate;

    private final ObservationRegistry observationRegistry;

    private final long pollIntervalMillis;

    private final long timeoutMillis;

    @Setter
    private ImageModelObservationConvention observationConvention = DEFAULT_OBSERVATION_CONVENTION;

    public TongYiImageModel(TongYiImageApi imageApi) {
        this(imageApi, TongYiImageOptions.builder().build(), RetryUtils.DEFAULT_RETRY_TEMPLATE,
                ObservationRegistry.NOOP, DEFAULT_POLL_INTERVAL_MILLIS, DEFAULT_TIMEOUT_MILLIS);
    }

    public TongYiImageModel(TongYiImageApi imageApi, TongYiImageOptions options, RetryTemplate retryTemplate) {
        this(imageApi, options, retryTemplate, ObservationRegistry.NOOP,
                DEFAULT_POLL_INTERVAL_MILLIS, DEFAULT_TIMEOUT_MILLIS);
    }

    public TongYiImageModel(TongYiImageApi imageApi, TongYiImageOptions options, RetryTemplate retryTemplate,
                            ObservationRegistry observationRegistry) {
        this(imageApi, options, retryTemplate, observationRegistry,
                DEFAULT_POLL_INTERVAL_MILLIS, DEFAULT_TIMEOUT_MILLIS);
    }

    public TongYiImageModel(TongYiImageApi imageApi, TongYiImageOptions options, RetryTemplate retryTemplate,
                            ObservationRegistry observationRegistry, long pollIntervalMillis, long timeoutMillis) {
        Assert.notNull(imageApi, "TongYiImageApi must not be null");
        Assert.notNull(options, "options must not be null");
        Assert.notNull(retryTemplate, "retryTemplate must not be null");
        Assert.notNull(observationRegistry, "observationRegistry must not be null");
        this.imageApi = imageApi;
        this.defaultOptions = options;
        this.retryTemplate = retryTemplate;
        this.observationRegistry = observationRegistry;
        this.pollIntervalMillis = pollIntervalMillis;
        this.timeoutMillis = timeoutMillis;
    }

    @Override
    public ImageResponse call(ImagePrompt imagePrompt) {
        TongYiImageOptions requestOptions = mergeOptions(imagePrompt.getOptions(), this.defaultOptions);
        TongYiImageApi.ImageSynthesisRequest request = buildRequest(imagePrompt, requestOptions);

        var observationContext = ImageModelObservationContext.builder()
                .imagePrompt(imagePrompt)
                .provider(TongYiImageApi.PROVIDER_NAME)
                .build();

        return ImageModelObservationDocumentation.IMAGE_MODEL_OPERATION
                .observation(this.observationConvention, DEFAULT_OBSERVATION_CONVENTION, () -> observationContext,
                        this.observationRegistry)
                .observe(() -> {
                    ImageResponse response = execute(request);
                    observationContext.setResponse(response);
                    return response;
                });
    }

    // ========== 创建任务 -> 轮询 -> 转换结果 ==========

    private ImageResponse execute(TongYiImageApi.ImageSynthesisRequest request) {
        // 1. 创建任务
        TongYiImageApi.TaskSubmitResponse submitResponse = RetryUtils.execute(this.retryTemplate,
                () -> this.imageApi.submit(request));
        String taskId = submitResponse.output() != null ? submitResponse.output().taskId() : null;
        if (StrUtil.isEmpty(taskId)) {
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 未返回 task_id：{}", submitResponse));
        }
        logger.debug("[execute][通义千问 文生图 任务创建成功 taskId({}) status({})]", taskId,
                submitResponse.output().taskStatus());

        // 2. 轮询任务结果
        long deadline = System.currentTimeMillis() + this.timeoutMillis;
        while (true) {
            TongYiImageApi.TaskResponse taskResponse = RetryUtils.execute(this.retryTemplate,
                    () -> this.imageApi.getTask(taskId));
            String status = taskResponse.output() != null ? taskResponse.output().taskStatus() : null;

            if (STATUS_SUCCEEDED.equals(status)) {
                return convertResponse(taskResponse, taskId);
            }
            if (isFailureStatus(status)) {
                throw new IllegalStateException(StrUtil.format("通义千问 文生图 任务({})执行失败：status({}) code({}) message({})",
                        taskId, status, resolveErrorCode(taskResponse), resolveErrorMessage(taskResponse)));
            }
            if (System.currentTimeMillis() >= deadline) {
                throw new IllegalStateException(StrUtil.format("通义千问 文生图 任务({})轮询超时（{} ms，最后状态 {}）",
                        taskId, this.timeoutMillis, status));
            }
            sleepQuietly(this.pollIntervalMillis, taskId);
        }
    }

    private static boolean isFailureStatus(@Nullable String status) {
        // 注意：不能用 Set.of(...).contains(status) —— 不可变集合的 contains(null) 会抛 NPE，
        // 而 status 完全可能为 null（响应结构异常时）
        return STATUS_FAILED.equals(status) || STATUS_CANCELED.equals(status) || STATUS_UNKNOWN.equals(status);
    }

    private static String resolveErrorCode(TongYiImageApi.TaskResponse response) {
        if (response.output() != null && StrUtil.isNotEmpty(response.output().code())) {
            return response.output().code();
        }
        return response.code();
    }

    private static String resolveErrorMessage(TongYiImageApi.TaskResponse response) {
        if (response.output() != null && StrUtil.isNotEmpty(response.output().message())) {
            return response.output().message();
        }
        return response.message();
    }

    private void sleepQuietly(long millis, String taskId) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException ex) {
            // 保留中断标记：任务被取消时不应该把中断吞掉
            Thread.currentThread().interrupt();
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 任务({})等待被中断", taskId), ex);
        }
    }

    private static ImageResponse convertResponse(TongYiImageApi.TaskResponse taskResponse, String taskId) {
        List<TongYiImageApi.TaskResponse.Result> results = taskResponse.output() != null
                ? taskResponse.output().results() : null;
        if (CollUtil.isEmpty(results)) {
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 任务({})成功但结果为空", taskId));
        }
        // 只取有 url 的结果：url 有效期 24 小时，调用方拿到后需立即下载
        List<ImageGeneration> generations = new ArrayList<>(results.size());
        for (TongYiImageApi.TaskResponse.Result result : results) {
            if (result == null || StrUtil.isEmpty(result.url())) {
                continue;
            }
            generations.add(new ImageGeneration(new Image(result.url(), null)));
        }
        if (generations.isEmpty()) {
            throw new IllegalStateException(StrUtil.format("通义千问 文生图 任务({})成功但未返回图片地址", taskId));
        }
        return new ImageResponse(generations);
    }

    private static TongYiImageApi.ImageSynthesisRequest buildRequest(ImagePrompt imagePrompt,
                                                                     TongYiImageOptions requestOptions) {
        String prompt = imagePrompt.getInstructions().getFirst().getText();
        return new TongYiImageApi.ImageSynthesisRequest(
                ModelOptionsUtils.mergeOption(requestOptions.getModel(), DEFAULT_IMAGE_MODEL),
                new TongYiImageApi.ImageSynthesisRequest.Input(prompt),
                new TongYiImageApi.ImageSynthesisRequest.Parameters(
                        requestOptions.getSize(),
                        requestOptions.getN(),
                        requestOptions.getNegativePrompt(),
                        requestOptions.getPromptExtend(),
                        requestOptions.getWatermark(),
                        requestOptions.getSeed()));
    }

    /**
     * 平台无关的运行时参数 + 默认参数合并
     */
    private TongYiImageOptions mergeOptions(@Nullable ImageOptions runtimeOptions, TongYiImageOptions defaultOptions) {
        if (runtimeOptions == null) {
            return defaultOptions;
        }
        TongYiImageOptions runtime = runtimeOptions instanceof TongYiImageOptions tongYiImageOptions
                ? tongYiImageOptions
                : TongYiImageOptions.builder()
                    .model(runtimeOptions.getModel())
                    .n(runtimeOptions.getN())
                    .width(runtimeOptions.getWidth())
                    .height(runtimeOptions.getHeight())
                    .build();

        return TongYiImageOptions.builder()
                .model(ModelOptionsUtils.mergeOption(runtime.getModel(), defaultOptions.getModel()))
                .n(ModelOptionsUtils.mergeOption(runtime.getN(), defaultOptions.getN()))
                .width(ModelOptionsUtils.mergeOption(runtime.getWidth(), defaultOptions.getWidth()))
                .height(ModelOptionsUtils.mergeOption(runtime.getHeight(), defaultOptions.getHeight()))
                .negativePrompt(ModelOptionsUtils.mergeOption(runtime.getNegativePrompt(), defaultOptions.getNegativePrompt()))
                .promptExtend(ModelOptionsUtils.mergeOption(runtime.getPromptExtend(), defaultOptions.getPromptExtend()))
                .watermark(ModelOptionsUtils.mergeOption(runtime.getWatermark(), defaultOptions.getWatermark()))
                .seed(ModelOptionsUtils.mergeOption(runtime.getSeed(), defaultOptions.getSeed()))
                .build();
    }

}
