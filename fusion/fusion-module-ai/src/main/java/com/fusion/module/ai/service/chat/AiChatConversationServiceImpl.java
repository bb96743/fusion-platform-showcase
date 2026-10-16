package com.fusion.module.ai.service.chat;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.ObjUtil;
import cn.hutool.core.util.ObjectUtil;
import com.fusion.module.ai.enums.model.AiModelTypeEnum;
import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.common.util.object.BeanUtils;
import com.fusion.module.ai.controller.admin.chat.vo.conversation.AiChatConversationCreateMyReqVO;
import com.fusion.module.ai.controller.admin.chat.vo.conversation.AiChatConversationPageReqVO;
import com.fusion.module.ai.controller.admin.chat.vo.conversation.AiChatConversationUpdateMyReqVO;
import com.fusion.module.ai.dal.dataobject.chat.AiChatConversationDO;
import com.fusion.module.ai.dal.dataobject.model.AiModelDO;
import com.fusion.module.ai.dal.dataobject.model.AiChatRoleDO;
import com.fusion.module.ai.dal.mysql.chat.AiChatConversationMapper;
import com.fusion.module.ai.service.knowledge.AiKnowledgeService;
import com.fusion.module.ai.service.model.AiModelService;
import com.fusion.module.ai.service.model.AiChatRoleService;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

import static com.fusion.framework.common.exception.util.ServiceExceptionUtil.exception;
import static com.fusion.framework.common.util.collection.CollectionUtils.convertList;
import static com.fusion.module.ai.enums.ErrorCodeConstants.CHAT_CONVERSATION_MODEL_ERROR;
import static com.fusion.module.ai.enums.ErrorCodeConstants.CHAT_CONVERSATION_NOT_EXISTS;

/**
 * AI 聊天对话 Service 实现类
 *
 * @author fansili
 */
@Service
@Validated
@Slf4j
public class AiChatConversationServiceImpl implements AiChatConversationService {

    @Resource
    private AiChatConversationMapper chatConversationMapper;

    @Resource
    private AiModelService modalService;
    @Resource
    private AiChatRoleService chatRoleService;
    @Resource
    private AiKnowledgeService knowledgeService;

    @Override
    public Long createChatConversationMy(AiChatConversationCreateMyReqVO createReqVO, Long userId) {
        // 1.1 获得 AiChatRoleDO 聊天角色
        AiChatRoleDO role = createReqVO.getRoleId() != null ? chatRoleService.validateChatRole(createReqVO.getRoleId()) : null;
        // 1.2 获得 AiModelDO 聊天模型
        // ⚠️ `ai_chat_role.model_id` 是 `NOT NULL DEFAULT 0`，**0 表示「未绑定、用默认模型」**，
        //    所以不能用 `!= null` 判断 —— 否则 0 会被当成模型编号去查，直接抛「模型不存在」，
        //    表现为「点角色仓库的『使用』按钮报错」，而 AI 写作 / AI 脑图却是好的。
        //    这里与 AiWriteServiceImpl#getModel、AiMindMapServiceImpl#getModel 保持一致：
        //    取不到（含 0、含已删除的模型）就回退到默认聊天模型。
        //    另外用 getAvailableModelOrNull：角色绑定的模型可能「模型开着、但密钥被禁用」，
        //    这种也当作不可用并回退，避免新建对话成功、一发消息才报「API 密钥已禁用！」（见 SOP 踩坑）。
        AiModelDO model = modalService.getAvailableModelOrNull(role != null ? role.getModelId() : null);
        if (model == null) {
            model = modalService.getRequiredDefaultModel(AiModelTypeEnum.CHAT.getType());
        }
        Assert.notNull(model, "必须找到默认模型");
        validateChatModel(model);

        // 1.3 校验知识库
        if (Objects.nonNull(createReqVO.getKnowledgeId())) {
            knowledgeService.validateKnowledgeExists(createReqVO.getKnowledgeId());
        }

        // 2. 创建 AiChatConversationDO 聊天对话
        AiChatConversationDO conversation = new AiChatConversationDO().setUserId(userId).setPinned(false)
                .setModelId(model.getId()).setModel(model.getModel())
                .setTemperature(model.getTemperature()).setMaxTokens(model.getMaxTokens()).setMaxContexts(model.getMaxContexts());
        if (role != null) {
            conversation.setTitle(role.getName()).setRoleId(role.getId()).setSystemMessage(role.getSystemMessage());
        } else {
            conversation.setTitle(AiChatConversationDO.TITLE_DEFAULT);
        }
        chatConversationMapper.insert(conversation);
        return conversation.getId();
    }

    @Override
    public void updateChatConversationMy(AiChatConversationUpdateMyReqVO updateReqVO, Long userId) {
        // 1.1 校验对话是否存在
        AiChatConversationDO conversation = validateChatConversationExists(updateReqVO.getId());
        if (ObjUtil.notEqual(conversation.getUserId(), userId)) {
            throw exception(CHAT_CONVERSATION_NOT_EXISTS);
        }
        // 1.2 校验模型是否存在（修改模型的情况）
        AiModelDO model = null;
        if (updateReqVO.getModelId() != null) {
            model = modalService.validateModel(updateReqVO.getModelId());
        }

        // 1.3 校验知识库是否存在
        if (updateReqVO.getKnowledgeId() != null) {
            knowledgeService.validateKnowledgeExists(updateReqVO.getKnowledgeId());
        }

        // 2. 更新对话信息
        AiChatConversationDO updateObj = BeanUtils.toBean(updateReqVO, AiChatConversationDO.class);
        if (Boolean.TRUE.equals(updateReqVO.getPinned())) {
            updateObj.setPinnedTime(LocalDateTime.now());
        }
        if (model != null) {
            updateObj.setModel(model.getModel());
        }
        chatConversationMapper.updateById(updateObj);
    }

    @Override
    public List<AiChatConversationDO> getChatConversationListByUserId(Long userId) {
        return chatConversationMapper.selectListByUserId(userId);
    }

    @Override
    public AiChatConversationDO getChatConversation(Long id) {
        return chatConversationMapper.selectById(id);
    }

    @Override
    public void deleteChatConversationMy(Long id, Long userId) {
        // 1. 校验对话是否存在
        AiChatConversationDO conversation = validateChatConversationExists(id);
        if (conversation == null || ObjUtil.notEqual(conversation.getUserId(), userId)) {
            throw exception(CHAT_CONVERSATION_NOT_EXISTS);
        }
        // 2. 执行删除
        chatConversationMapper.deleteById(id);
    }

    @Override
    public void deleteChatConversationByAdmin(Long id) {
        // 1. 校验对话是否存在
        AiChatConversationDO conversation = validateChatConversationExists(id);
        if (conversation == null) {
            throw exception(CHAT_CONVERSATION_NOT_EXISTS);
        }
        // 2. 执行删除
        chatConversationMapper.deleteById(id);
    }

    private void validateChatModel(AiModelDO model) {
        if (ObjectUtil.isAllNotEmpty(model.getTemperature(), model.getMaxTokens(), model.getMaxContexts())) {
            return;
        }
        Assert.equals(model.getType(), AiModelTypeEnum.CHAT.getType(), "模型类型不正确：" + model);
        throw exception(CHAT_CONVERSATION_MODEL_ERROR);
    }

    public AiChatConversationDO validateChatConversationExists(Long id) {
        AiChatConversationDO conversation = chatConversationMapper.selectById(id);
        if (conversation == null) {
            throw exception(CHAT_CONVERSATION_NOT_EXISTS);
        }
        return conversation;
    }

    @Override
    public void deleteChatConversationMyByUnpinned(Long userId) {
        List<AiChatConversationDO> list = chatConversationMapper.selectListByUserIdAndPinned(userId, false);
        if (CollUtil.isEmpty(list)) {
            return;
        }
        chatConversationMapper.deleteByIds(convertList(list, AiChatConversationDO::getId));
    }

    @Override
    public PageResult<AiChatConversationDO> getChatConversationPage(AiChatConversationPageReqVO pageReqVO) {
        return chatConversationMapper.selectChatConversationPage(pageReqVO);
    }

}
