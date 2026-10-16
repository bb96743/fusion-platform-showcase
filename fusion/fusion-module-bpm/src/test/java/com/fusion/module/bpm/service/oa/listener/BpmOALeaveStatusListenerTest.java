package com.fusion.module.bpm.service.oa.listener;

import com.fusion.framework.test.core.ut.BaseMockitoUnitTest;
import com.fusion.module.bpm.api.event.BpmProcessInstanceStatusEvent;
import com.fusion.module.bpm.service.oa.BpmOALeaveService;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import static org.mockito.Mockito.verify;

/**
 * {@link BpmOALeaveStatusListener} 的单元测试
 *
 * @author HUIHUI
 */
public class BpmOALeaveStatusListenerTest extends BaseMockitoUnitTest {

    @InjectMocks
    private BpmOALeaveStatusListener leaveStatusListener;

    @Mock
    private BpmOALeaveService leaveService;

    @Test
    public void testOnApplicationEvent_sameProcessDefinitionKey_updateStatus() {
        // 准备参数
        BpmProcessInstanceStatusEvent event = new BpmProcessInstanceStatusEvent(this);
        event.setProcessDefinitionKey("oa_leave").setBusinessKey("1").setStatus(2);

        // 调用
        leaveStatusListener.onApplicationEvent(event);
        // 断言
        verify(leaveService).updateLeaveStatus(1L, 2);
    }

    @Test
    public void testOnApplicationEvent_differentProcessDefinitionKey_ignore() {
        // 准备参数
        BpmProcessInstanceStatusEvent event = new BpmProcessInstanceStatusEvent(this);
        event.setProcessDefinitionKey("oa_reimbursement").setBusinessKey("1").setStatus(2);

        // 调用
        leaveStatusListener.onApplicationEvent(event);
        // 断言
        org.mockito.Mockito.verifyNoInteractions(leaveService);
    }

}
