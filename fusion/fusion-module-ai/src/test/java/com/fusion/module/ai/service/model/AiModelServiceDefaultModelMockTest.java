package com.fusion.module.ai.service.model;

import com.fusion.framework.common.enums.CommonStatusEnum;
import com.fusion.framework.common.exception.ServiceException;
import com.fusion.framework.test.core.ut.BaseMockitoUnitTest;
import com.fusion.module.ai.dal.dataobject.model.AiApiKeyDO;
import com.fusion.module.ai.dal.dataobject.model.AiModelDO;
import com.fusion.module.ai.dal.mysql.model.AiChatMapper;
import com.fusion.module.ai.enums.ErrorCodeConstants;
import com.fusion.module.ai.enums.model.AiModelTypeEnum;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

/**
 * {@link AiModelServiceImpl#getRequiredDefaultModel} 的回归测试
 *
 * <h3>为什么要钉它</h3>
 * 「默认模型」的候选来自 {@code ai_model} 表（{@code status=开启} + {@code sort} 最小），
 * 但**能不能真的调用**还取决于它绑定的 {@code ai_api_key} 是否开启 —— 这是**两张表、两个独立开关**。
 *
 * <p>修复前的行为：只看 {@code ai_model.status}，于是「模型开着、密钥被禁用」的候选
 * 会被选为默认模型 → 用户表现为
 * <b>「我每次新建对话，默认都是我已经关掉的那个模型」</b>，
 * 而且发消息才报「API 密钥已禁用！」，从界面上完全看不出是配置矛盾。
 *
 * <p>修复后：跳过密钥不可用的候选，往后取第一个真正可用的；全都不可用才报
 * {@link ErrorCodeConstants#MODEL_DEFAULT_NOT_AVAILABLE}（可读、可自查）。
 *
 * <p>本测试与上游无关、不联网、不烧 token，可进 CI。
 *
 * @author fansili
 */
public class AiModelServiceDefaultModelMockTest extends BaseMockitoUnitTest {

    @InjectMocks
    private AiModelServiceImpl modelService;

    @Mock
    private AiChatMapper modelMapper;
    @Mock
    private AiApiKeyService apiKeyService;

    private static final Integer CHAT = AiModelTypeEnum.CHAT.getType();

    /**
     * 核心回归：sort 最小的模型其密钥被禁用 → 必须跳到下一个可用的模型
     *
     * 对应真实场景：千问(qwen-plus, sort=0, key=2 已禁用) + DeepSeek(deepseek-chat, sort=1, key=1 开启)
     * → 应该选中 DeepSeek，而不是千问。
     */
    @Test
    public void testGetRequiredDefaultModel_skipModelWhoseApiKeyDisabled() {
        // 准备参数：候选按 sort 升序，第一个（千问）的密钥是禁用的
        AiModelDO qwen = AiModelDO.builder().id(2L).name("通义千问 Plus").model("qwen-plus")
                .keyId(2L).type(CHAT).sort(0).status(CommonStatusEnum.ENABLE.getStatus()).build();
        AiModelDO deepSeek = AiModelDO.builder().id(1L).name("DeepSeek Chat").model("deepseek-chat")
                .keyId(1L).type(CHAT).sort(1).status(CommonStatusEnum.ENABLE.getStatus()).build();
        when(modelMapper.selectListByStatusAndType(eq(CommonStatusEnum.ENABLE.getStatus()), eq(CHAT), any()))
                .thenReturn(List.of(qwen, deepSeek));
        when(apiKeyService.getApiKey(2L)).thenReturn(AiApiKeyDO.builder().id(2L)
                .status(CommonStatusEnum.DISABLE.getStatus()).build());
        when(apiKeyService.getApiKey(1L)).thenReturn(AiApiKeyDO.builder().id(1L)
                .status(CommonStatusEnum.ENABLE.getStatus()).build());

        // 调用
        AiModelDO result = modelService.getRequiredDefaultModel(CHAT);

        // 断言：选中的是 DeepSeek，不是 sort 更小的千问
        assertEquals(1L, result.getId());
        assertEquals("deepseek-chat", result.getModel());
    }

    /**
     * 都可用时，仍然遵守「sort 最小者优先」的原语义（避免修复引入行为回归）
     */
    @Test
    public void testGetRequiredDefaultModel_firstWhenAllAvailable() {
        // 准备参数
        AiModelDO qwen = AiModelDO.builder().id(2L).model("qwen-plus")
                .keyId(2L).type(CHAT).sort(0).status(CommonStatusEnum.ENABLE.getStatus()).build();
        AiModelDO deepSeek = AiModelDO.builder().id(1L).model("deepseek-chat")
                .keyId(1L).type(CHAT).sort(1).status(CommonStatusEnum.ENABLE.getStatus()).build();
        when(modelMapper.selectListByStatusAndType(eq(CommonStatusEnum.ENABLE.getStatus()), eq(CHAT), any()))
                .thenReturn(List.of(qwen, deepSeek));
        when(apiKeyService.getApiKey(2L)).thenReturn(AiApiKeyDO.builder().id(2L)
                .status(CommonStatusEnum.ENABLE.getStatus()).build());

        // 调用
        AiModelDO result = modelService.getRequiredDefaultModel(CHAT);

        // 断言：sort 最小者优先，没被改坏
        assertEquals("qwen-plus", result.getModel());
    }

    /**
     * 一个候选都没有（没有已开启的模型）→ 保持原有错误码
     */
    @Test
    public void testGetRequiredDefaultModel_noModel() {
        // 准备参数
        when(modelMapper.selectListByStatusAndType(eq(CommonStatusEnum.ENABLE.getStatus()), eq(CHAT), any()))
                .thenReturn(Collections.emptyList());

        // 调用并断言
        ServiceException ex = assertThrows(ServiceException.class,
                () -> modelService.getRequiredDefaultModel(CHAT));
        assertEquals(ErrorCodeConstants.MODEL_DEFAULT_NOT_EXISTS.getCode().intValue(), ex.getCode().intValue());
    }

    /**
     * 有模型、但所有模型的密钥都不可用 → 报可读的 MODEL_DEFAULT_NOT_AVAILABLE，
     * 而不是含糊的「找不到默认模型」，让用户能顺着提示去查密钥开关。
     */
    @Test
    public void testGetRequiredDefaultModel_allApiKeysDisabled() {
        // 准备参数
        AiModelDO qwen = AiModelDO.builder().id(2L).model("qwen-plus")
                .keyId(2L).type(CHAT).sort(0).status(CommonStatusEnum.ENABLE.getStatus()).build();
        when(modelMapper.selectListByStatusAndType(eq(CommonStatusEnum.ENABLE.getStatus()), eq(CHAT), any()))
                .thenReturn(List.of(qwen));
        when(apiKeyService.getApiKey(2L)).thenReturn(AiApiKeyDO.builder().id(2L)
                .status(CommonStatusEnum.DISABLE.getStatus()).build());

        // 调用并断言
        ServiceException ex = assertThrows(ServiceException.class,
                () -> modelService.getRequiredDefaultModel(CHAT));
        assertEquals(ErrorCodeConstants.MODEL_DEFAULT_NOT_AVAILABLE.getCode().intValue(), ex.getCode().intValue());
    }

    /**
     * 密钥记录被删掉（getApiKey 返回 null）也要能跳过，不能抛 NPE
     */
    @Test
    public void testGetRequiredDefaultModel_skipDeletedApiKey() {
        // 准备参数：模型绑的密钥已不存在
        AiModelDO broken = AiModelDO.builder().id(2L).model("qwen-plus")
                .keyId(99L).type(CHAT).sort(0).status(CommonStatusEnum.ENABLE.getStatus()).build();
        AiModelDO ok = AiModelDO.builder().id(1L).model("deepseek-chat")
                .keyId(1L).type(CHAT).sort(1).status(CommonStatusEnum.ENABLE.getStatus()).build();
        when(modelMapper.selectListByStatusAndType(eq(CommonStatusEnum.ENABLE.getStatus()), eq(CHAT), any()))
                .thenReturn(List.of(broken, ok));
        when(apiKeyService.getApiKey(99L)).thenReturn(null);
        when(apiKeyService.getApiKey(1L)).thenReturn(AiApiKeyDO.builder().id(1L)
                .status(CommonStatusEnum.ENABLE.getStatus()).build());

        // 调用
        AiModelDO result = modelService.getRequiredDefaultModel(CHAT);

        // 断言
        assertEquals("deepseek-chat", result.getModel());
    }

    // ========== getAvailableModelOrNull：角色显式绑定模型时的「可用性」判断 ==========

    /**
     * 角色绑定的模型「模型开着、但绑定的密钥被禁用」→ 视为不可用，返回 null
     * （调用方据此回退默认模型，而不是等发消息时才报「API 密钥已禁用！」）
     */
    @Test
    public void testGetAvailableModelOrNull_modelOnButApiKeyDisabled() {
        // 准备参数
        when(modelMapper.selectById(2L)).thenReturn(AiModelDO.builder().id(2L).model("qwen-plus")
                .keyId(2L).type(CHAT).sort(0).status(CommonStatusEnum.ENABLE.getStatus()).build());
        when(apiKeyService.getApiKey(2L)).thenReturn(AiApiKeyDO.builder().id(2L)
                .status(CommonStatusEnum.DISABLE.getStatus()).build());

        // 调用并断言
        assertNull(modelService.getAvailableModelOrNull(2L));
    }

    /**
     * 模型与密钥都正常 → 正常返回（避免把「可用」误判成「不可用」而总是回退默认模型）
     */
    @Test
    public void testGetAvailableModelOrNull_available() {
        // 准备参数
        when(modelMapper.selectById(1L)).thenReturn(AiModelDO.builder().id(1L).model("deepseek-chat")
                .keyId(1L).type(CHAT).sort(1).status(CommonStatusEnum.ENABLE.getStatus()).build());
        when(apiKeyService.getApiKey(1L)).thenReturn(AiApiKeyDO.builder().id(1L)
                .status(CommonStatusEnum.ENABLE.getStatus()).build());

        // 调用
        AiModelDO result = modelService.getAvailableModelOrNull(1L);

        // 断言
        assertNotNull(result);
        assertEquals("deepseek-chat", result.getModel());
    }

    /**
     * 角色「未绑定模型」时传 null 要安全返回 null，不能抛异常
     * （`ai_chat_role.model_id` 是 NOT NULL DEFAULT 0，0 就是「不绑定」的哨兵值）
     */
    @Test
    public void testGetAvailableModelOrNull_nullAndZeroSafe() {
        // null：角色为空时直接返回 null，连查库都不该发生
        assertNull(modelService.getAvailableModelOrNull(null));
        // 0（哨兵值）：查不到 → null
        when(modelMapper.selectById(0L)).thenReturn(null);
        assertNull(modelService.getAvailableModelOrNull(0L));
    }

    /**
     * 模型本身已被关闭 → 不可用
     */
    @Test
    public void testGetAvailableModelOrNull_modelDisabled() {
        // 准备参数
        when(modelMapper.selectById(1L)).thenReturn(AiModelDO.builder().id(1L).model("deepseek-chat")
                .keyId(1L).type(CHAT).sort(1).status(CommonStatusEnum.DISABLE.getStatus()).build());

        // 调用并断言
        assertNull(modelService.getAvailableModelOrNull(1L));
    }

}
