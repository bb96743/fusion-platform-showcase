package com.fusion.module.ai.framework.ai.core.model.dashscope;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.ai.image.ImageOptions;

/**
 * 通义千问（DashScope <b>原生</b>协议）的 {@link ImageOptions}
 *
 * 为什么不用 {@code com.alibaba.cloud.ai.dashscope.image.DashScopeImageOptions}：
 * 它所属的 spring-ai-alibaba 2.0.0-M1.1 与 Spring AI 2.0.0 不兼容（见 {@link TongYiImageModel} 类说明）。
 * 本类只用「平台无关」的字段，避免把不兼容的第三方类型带进运行链路。
 *
 * @author fansili
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TongYiImageOptions implements ImageOptions {

    /**
     * 模型名，例如 wan2.6-t2i、wanx2.1-t2i-turbo
     */
    private String model;

    /**
     * 生成张数，取值 1 ~ 4
     */
    private Integer n;

    /**
     * 宽（像素）
     */
    private Integer width;

    /**
     * 高（像素）
     */
    private Integer height;

    /**
     * 反向提示词
     */
    private String negativePrompt;

    /**
     * 是否开启提示词智能改写（DashScope 默认 true）
     */
    private Boolean promptExtend;

    /**
     * 是否添加「AI生成」水印
     */
    private Boolean watermark;

    /**
     * 随机种子
     */
    private Integer seed;

    /**
     * DashScope 用 "宽*高" 的字符串表达分辨率；宽高缺一时交给服务端默认值
     */
    public String getSize() {
        return width != null && height != null ? width + "*" + height : null;
    }

    @Override
    public String getResponseFormat() {
        return "url";
    }

    @Override
    public String getStyle() {
        return null;
    }

}
