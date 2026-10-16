package com.fusion.module.ai.framework.ai.core.websearch;

import com.fusion.framework.common.util.json.JsonUtils;
import com.fusion.module.ai.framework.ai.core.webserch.AiWebSearchRequest;
import com.fusion.module.ai.framework.ai.core.webserch.AiWebSearchResponse;
import com.fusion.module.ai.framework.ai.core.webserch.bocha.AiBoChaWebSearchClient;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

/**
 * {@link AiBoChaWebSearchClient} 集成测试类
 *
 */
public class AiBoChaWebSearchClientTest {

    private final AiBoChaWebSearchClient webSearchClient = new AiBoChaWebSearchClient(
            // ⚠️ 原先是上游硬编码的真实密钥，已随 F0 移除（见 需求分析文档.md 13.16）。
            //    需要跑这个集成测试时用环境变量提供：BOCHA_API_KEY=xxx
            System.getenv().getOrDefault("BOCHA_API_KEY", ""));

    @Test
    @Disabled
    public void testSearch() {
        AiWebSearchRequest request = new AiWebSearchRequest()
                .setQuery("阿里巴巴")
                .setCount(3);
        AiWebSearchResponse response = webSearchClient.search(request);
        System.out.println(JsonUtils.toJsonPrettyString(response));
    }

}