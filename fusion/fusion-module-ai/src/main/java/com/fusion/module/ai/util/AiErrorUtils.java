package com.fusion.module.ai.util;

import cn.hutool.core.util.StrUtil;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.net.ConnectException;
import java.net.UnknownHostException;
import java.util.concurrent.TimeoutException;

/**
 * 大模型调用异常的「可读化」工具类
 *
 * 背景：上游多处把流式异常统一压成一句话就返回给前端，例如
 * {@code Flux.just(error(CHAT_STREAM_ERROR))} → 用户只看到「对话生成异常!」，
 * 完全不知道是密钥错了、限流了还是网络不通 —— 本次排查 401 密钥问题时就靠翻后端日志才定位到。
 *
 * 本工具把异常翻译成**用户能照着做**的提示，并做**密钥脱敏**兜底。
 */
public class AiErrorUtils {

    private AiErrorUtils() {}

    /**
     * 把大模型调用异常翻译成可读、可操作、且不泄露密钥的提示
     *
     * @param error 原始异常
     * @return 面向用户的提示文案
     */
    public static String describeAiError(Throwable error) {
        if (error == null) {
            return "调用大模型失败，请稍后重试";
        }
        // 1. 向下找根因，同时记录沿途的 HTTP 状态码
        Integer httpStatus = null;
        Throwable root = error;
        for (int i = 0; i < 8 && root != null; i++) {
            if (root instanceof WebClientResponseException responseException) {
                httpStatus = responseException.getStatusCode().value();
            }
            Throwable cause = root.getCause();
            if (cause == null || cause == root) {
                break;
            }
            root = cause;
        }
        // 2. 按状态码给出最常见的几种处置建议
        if (httpStatus != null) {
            if (httpStatus == 401 || httpStatus == 403) {
                return "大模型返回 " + httpStatus + "，API 密钥无效或无权限。"
                        + "请到「AI 大模型 → API 密钥」检查密钥是否填写正确、是否已过期";
            }
            if (httpStatus == 404) {
                return "大模型返回 404，接口地址或模型标识（model）不存在，请检查模型配置";
            }
            if (httpStatus == 429) {
                return "大模型返回 429，调用频率或额度超限，请稍后重试或检查账户余额";
            }
            if (httpStatus >= 500) {
                return "大模型服务返回 " + httpStatus + "，对方服务异常，请稍后重试";
            }
            return "大模型返回 HTTP " + httpStatus + "，请检查模型与密钥配置";
        }
        // 3. 网络类异常
        for (Throwable t = error; t != null; t = (t.getCause() == t ? null : t.getCause())) {
            if (t instanceof TimeoutException) {
                return "调用大模型超时，请检查网络，或稍后重试";
            }
            if (t instanceof ConnectException || t instanceof UnknownHostException) {
                return "无法连接大模型服务，请检查网络，或核对 API 密钥里配置的「自定义 API 地址」";
            }
        }
        // 4. 兜底：带上简短原因（脱敏）
        String message = root != null && StrUtil.isNotBlank(root.getMessage())
                ? root.getMessage() : String.valueOf(error);
        return "调用大模型失败：" + maskSecret(message);
    }

    /**
     * 抹掉文本中可能出现的密钥
     *
     * 之所以必须做：部分平台会把请求里的密钥原样回显在错误信息中
     * （DeepSeek 是打码的 {@code ****e-me}，但不能假定所有平台都打码）。
     */
    public static String maskSecret(String message) {
        if (StrUtil.isBlank(message)) {
            return "未知错误";
        }
        String masked = message
                .replaceAll("(?i)(sk-|ak-)[A-Za-z0-9_\\-]{6,}", "$1****")
                .replaceAll("(?i)(Bearer\\s+)[A-Za-z0-9_\\-.]{6,}", "$1****")
                .replaceAll("(?i)(api[_-]?key\"?\\s*[:=]\\s*\"?)[A-Za-z0-9_\\-]{6,}", "$1****");
        return masked.length() > 180 ? masked.substring(0, 180) + "…" : masked;
    }

}
