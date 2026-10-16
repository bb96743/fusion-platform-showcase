package com.fusion.framework.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 文档地址
 *
 */
@Getter
@AllArgsConstructor
public enum DocumentEnum {

    REDIS_INSTALL("/issues/I4VCSJ", "Redis 安装文档"),
    TENANT("https://fusion.example.com", "SaaS 多租户文档");

    private final String url;
    private final String memo;

}
