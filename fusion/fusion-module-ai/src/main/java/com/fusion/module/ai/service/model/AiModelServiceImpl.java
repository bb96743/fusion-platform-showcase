package com.fusion.module.ai.service.model;

import com.fusion.module.ai.enums.model.AiModelTypeEnum;
import com.fusion.module.ai.enums.model.AiPlatformEnum;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjUtil;
import cn.hutool.core.util.StrUtil;
import com.fusion.module.ai.framework.ai.core.model.AiModelFactory;
import com.fusion.module.ai.framework.ai.core.model.midjourney.api.MidjourneyApi;
import com.fusion.module.ai.framework.ai.core.model.suno.api.SunoApi;
import com.fusion.framework.common.enums.CommonStatusEnum;
import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.common.util.object.BeanUtils;
import com.fusion.module.ai.enums.ErrorCodeConstants;
import com.fusion.module.ai.controller.admin.model.vo.model.AiModelPageReqVO;
import com.fusion.module.ai.controller.admin.model.vo.model.AiModelSaveReqVO;
import com.fusion.module.ai.dal.dataobject.model.AiApiKeyDO;
import com.fusion.module.ai.dal.dataobject.model.AiModelDO;
import com.fusion.module.ai.dal.mysql.model.AiChatMapper;
import com.agentsflex.llm.deepseek.DeepseekConfig;
import com.agentsflex.llm.deepseek.DeepseekLlm;
import com.agentsflex.llm.ollama.OllamaLlm;
import com.agentsflex.llm.ollama.OllamaLlmConfig;
import com.agentsflex.llm.qwen.QwenLlm;
import com.agentsflex.llm.qwen.QwenLlmConfig;
import dev.tinyflow.core.Tinyflow;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.image.ImageModel;
import org.springframework.ai.vectorstore.SimpleVectorStore;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.util.List;
import java.util.Map;

import static com.fusion.framework.common.exception.util.ServiceExceptionUtil.exception;
import static com.fusion.module.ai.enums.ErrorCodeConstants.*;

/**
 * AI 模型 Service 实现类
 *
 * @author fansili
 */
@Service
@Validated
@Slf4j
public class AiModelServiceImpl implements AiModelService {

    @Resource
    private AiApiKeyService apiKeyService;

    @Resource
    private AiChatMapper modelMapper;

    @Resource
    private AiModelFactory modelFactory;

    @Override
    public Long createModel(AiModelSaveReqVO createReqVO) {
        // 1. 校验
        AiPlatformEnum.validatePlatform(createReqVO.getPlatform());
        apiKeyService.validateApiKey(createReqVO.getKeyId());

        // 2. 插入
        AiModelDO model = BeanUtils.toBean(createReqVO, AiModelDO.class);
        modelMapper.insert(model);
        return model.getId();
    }

    @Override
    public void updateModel(AiModelSaveReqVO updateReqVO) {
        // 1. 校验
        validateModelExists(updateReqVO.getId());
        AiPlatformEnum.validatePlatform(updateReqVO.getPlatform());
        apiKeyService.validateApiKey(updateReqVO.getKeyId());

        // 2. 更新
        AiModelDO updateObj = BeanUtils.toBean(updateReqVO, AiModelDO.class);
        modelMapper.updateById(updateObj);
    }

    @Override
    public void deleteModel(Long id) {
        // 校验存在
        validateModelExists(id);
        // 删除
        modelMapper.deleteById(id);
    }

    private AiModelDO validateModelExists(Long id) {
        AiModelDO model = modelMapper.selectById(id);
        if (modelMapper.selectById(id) == null) {
            throw exception(MODEL_NOT_EXISTS);
        }
        return model;
    }

    @Override
    public AiModelDO getModel(Long id) {
        return modelMapper.selectById(id);
    }

    @Override
    public AiModelDO getRequiredDefaultModel(Integer type) {
        // 候选模型：开启状态 + 指定类型，按 sort 升序（sort 最小者优先，与 AiModelDO 类注释一致）
        List<AiModelDO> models = modelMapper.selectListByStatusAndType(
                CommonStatusEnum.ENABLE.getStatus(), type, null);
        if (CollUtil.isEmpty(models)) {
            throw exception(MODEL_DEFAULT_NOT_EXISTS);
        }
        // ⚠️ 必须连同「API 密钥是否可用」一起判断，否则会出现：
        //    ai_model.status 与 ai_api_key.status 是两张表、两个独立开关；
        //    模型开着、但它绑定的密钥被禁用时，这里仍会选中该模型 →
        //    用户「每次新建对话默认都是我已经关掉的那个模型」，发消息才报「API 密钥已禁用！」。
        //    所以跳过密钥不可用的候选，往后取第一个真正能用的；都不可用才报错。
        for (AiModelDO model : models) {
            if (isApiKeyAvailable(model.getKeyId())) {
                return model;
            }
        }
        throw exception(MODEL_DEFAULT_NOT_AVAILABLE);
    }

    /**
     * 判断模型绑定的 API 密钥是否可用（存在 + 开启）
     *
     * 刻意不抛异常：这里只是「挑一个能用的模型」，遇不可用跳过即可；
     * 真正的报错交给「一个都挑不出来」时抛出的 {@link ErrorCodeConstants#MODEL_DEFAULT_NOT_AVAILABLE}。
     */
    private boolean isApiKeyAvailable(Long keyId) {
        if (keyId == null) {
            return false;
        }
        AiApiKeyDO apiKey = apiKeyService.getApiKey(keyId);
        return apiKey != null && CommonStatusEnum.isEnable(apiKey.getStatus());
    }

    @Override
    public AiModelDO getAvailableModelOrNull(Long id) {
        if (id == null) {
            return null;
        }
        AiModelDO model = modelMapper.selectById(id);
        if (model == null) {
            return null;
        }
        // 已关闭的模型不能用
        if (CommonStatusEnum.isDisable(model.getStatus())) {
            return null;
        }
        // 模型开着、但绑定的密钥被禁用 —— 这是最容易漏的一种「看起来配好了其实不能用」
        if (!isApiKeyAvailable(model.getKeyId())) {
            return null;
        }
        return model;
    }

    @Override
    public PageResult<AiModelDO> getModelPage(AiModelPageReqVO pageReqVO) {
        return modelMapper.selectPage(pageReqVO);
    }

    @Override
    public AiModelDO validateModel(Long id) {
        AiModelDO model = validateModelExists(id);
        if (CommonStatusEnum.isDisable(model.getStatus())) {
            throw exception(MODEL_DISABLE);
        }
        return model;
    }

    @Override
    public List<AiModelDO> getModelListByStatusAndType(Integer status, Integer type, String platform) {
        return modelMapper.selectListByStatusAndType(status, type, platform);
    }

    // ========== 与 Spring AI 集成 ==========

    @Override
    public ChatModel getChatModel(Long id) {
        AiModelDO model = validateModel(id);
        AiApiKeyDO apiKey = apiKeyService.validateApiKey(model.getKeyId());
        AiPlatformEnum platform = AiPlatformEnum.validatePlatform(apiKey.getPlatform());
        return modelFactory.getOrCreateChatModel(platform, apiKey.getApiKey(), apiKey.getUrl());
    }

    @Override
    public ImageModel getImageModel(Long id) {
        AiModelDO model = validateModel(id);
        // 与 write / mindmap / chat 保持一致：用错类型的模型要在这里就拦下来。
        // 否则会把「对话模型名」当成绘图模型名发给上游，报一个与真实原因无关的错误。
        if (ObjUtil.notEqual(model.getType(), AiModelTypeEnum.IMAGE.getType())) {
            throw exception(MODEL_USE_TYPE_ERROR);
        }
        AiApiKeyDO apiKey = apiKeyService.validateApiKey(model.getKeyId());
        AiPlatformEnum platform = AiPlatformEnum.validatePlatform(apiKey.getPlatform());
        return modelFactory.getOrCreateImageModel(platform, apiKey.getApiKey(), apiKey.getUrl());
    }

    @Override
    public MidjourneyApi getMidjourneyApi(Long id) {
        AiModelDO model = validateModel(id);
        AiApiKeyDO apiKey = apiKeyService.validateApiKey(model.getKeyId());
        return modelFactory.getOrCreateMidjourneyApi(apiKey.getApiKey(), apiKey.getUrl());
    }

    @Override
    public SunoApi getSunoApi() {
        AiApiKeyDO apiKey = apiKeyService.getRequiredDefaultApiKey(
                AiPlatformEnum.SUNO.getPlatform(), CommonStatusEnum.ENABLE.getStatus());
        return modelFactory.getOrCreateSunoApi(apiKey.getApiKey(), apiKey.getUrl());
    }

    @Override
    public VectorStore getOrCreateVectorStore(Long id, Map<String, Class<?>> metadataFields) {
        // 获取模型 + 密钥
        AiModelDO model = validateModel(id);
        // 知识库的向量化必须用「向量」类型的模型：传对话模型进来（很常见的误配）
        // 会把 qwen-plus 之类的模型名发到 /embeddings，报出与真实原因无关的上游错误
        if (ObjUtil.notEqual(model.getType(), AiModelTypeEnum.EMBEDDING.getType())) {
            throw exception(MODEL_USE_TYPE_ERROR);
        }
        AiApiKeyDO apiKey = apiKeyService.validateApiKey(model.getKeyId());
        AiPlatformEnum platform = AiPlatformEnum.validatePlatform(apiKey.getPlatform());

        // 创建或获取 EmbeddingModel 对象
        EmbeddingModel embeddingModel = modelFactory.getOrCreateEmbeddingModel(
                platform, apiKey.getApiKey(), apiKey.getUrl(), model.getModel());

        // 创建或获取 VectorStore 对象
         return modelFactory.getOrCreateVectorStore(SimpleVectorStore.class, embeddingModel, metadataFields);
//         return modelFactory.getOrCreateVectorStore(QdrantVectorStore.class, embeddingModel, metadataFields);
//         return modelFactory.getOrCreateVectorStore(RedisVectorStore.class, embeddingModel, metadataFields);
//         return modelFactory.getOrCreateVectorStore(MilvusVectorStore.class, embeddingModel, metadataFields);
    }

    // TODO @lesan：是不是返回 Llm 对象会好点哈？
    @Override
    public void getLLmProvider4Tinyflow(Tinyflow tinyflow, Long modelId) {
        AiModelDO model = validateModel(modelId);
        AiApiKeyDO apiKey = apiKeyService.validateApiKey(model.getKeyId());
        AiPlatformEnum platform = AiPlatformEnum.validatePlatform(apiKey.getPlatform());
        switch (platform) {
            // TODO @lesan 考虑到未来不需要使用agents-flex 现在仅测试通义千问
            // TODO @lesan：【重要】是不是可以实现一个 SpringAiLlm，这样的话，内部全部用它就好了。只实现 chat 部分；这样，就把 flex 作为一个 agent 框架，内部调用，还是 spring ai 相关的。成本可能低一点？！
            case TONG_YI:
                QwenLlmConfig qwenLlmConfig = new QwenLlmConfig();
                qwenLlmConfig.setApiKey(apiKey.getApiKey());
                qwenLlmConfig.setModel(model.getModel());
                // TODO @lesan：这个有点奇怪。。。如果一个链式里，有多个模型，咋整呀。。。
                tinyflow.setLlmProvider(id -> new QwenLlm(qwenLlmConfig));
                break;
            case OLLAMA:
                OllamaLlmConfig ollamaLlmConfig = new OllamaLlmConfig();
                ollamaLlmConfig.setEndpoint(apiKey.getUrl());
                ollamaLlmConfig.setModel(model.getModel());
                tinyflow.setLlmProvider(id -> new OllamaLlm(ollamaLlmConfig));
                break;
            case DEEP_SEEK:
                // ⚠️ 补这一支的原因（2026-10-12 实测）：AI 工作流的「大模型」节点原先只认
                //    TONG_YI / OLLAMA。当千问那枚密钥不可用（被关闭或账号欠费）时，
                //    工作流会拿不到 provider，在 agents-flex LlmNode 里抛
                //    `NullPointerException: "this.llm" is null` —— 界面上只看到「系统异常」。
                //    DeepSeek 用的是 agents-flex 同族客户端（agents-flex-llm-deepseek 已在依赖里），
                //    接线方式与 TONG_YI 同构。
                DeepseekConfig deepseekConfig = new DeepseekConfig();
                deepseekConfig.setApiKey(apiKey.getApiKey());
                deepseekConfig.setModel(model.getModel());
                // 允许用「API 密钥」里的 url 覆盖默认端点（换私有网关时用）
                if (StrUtil.isNotBlank(apiKey.getUrl())) {
                    deepseekConfig.setEndpoint(apiKey.getUrl());
                }
                tinyflow.setLlmProvider(id -> new DeepseekLlm(deepseekConfig));
                break;
            default:
                // 其余平台暂无 agents-flex 客户端接线；留日志便于定位「工作流跑不动」这类问题
                log.warn("[getLLmProvider4Tinyflow][平台({})暂无 tinyflow 的 LLM 接线，模型({})将不可用于工作流]",
                        platform.getPlatform(), model.getId());
                break;
        }
    }

}
