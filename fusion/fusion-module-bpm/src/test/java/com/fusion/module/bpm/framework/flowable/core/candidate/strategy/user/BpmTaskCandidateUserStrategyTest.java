package com.fusion.module.bpm.framework.flowable.core.candidate.strategy.user;

import com.fusion.framework.test.core.ut.BaseMockitoUnitTest;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;

import java.util.Set;

import static com.fusion.framework.common.util.collection.SetUtils.asSet;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class BpmTaskCandidateUserStrategyTest extends BaseMockitoUnitTest {

    @InjectMocks
    private BpmTaskCandidateUserStrategy strategy;

    @Test
    public void test() {
        // 准备参数
        String param = "1,2";

        // 调用
        Set<Long> userIds = strategy.calculateUsersByTask(null, param);
        // 断言
        assertEquals(asSet(1L, 2L), userIds);
    }

}
