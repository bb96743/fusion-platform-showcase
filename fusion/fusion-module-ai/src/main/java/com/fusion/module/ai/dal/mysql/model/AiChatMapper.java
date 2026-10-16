package com.fusion.module.ai.dal.mysql.model;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.ai.controller.admin.model.vo.model.AiModelPageReqVO;
import com.fusion.module.ai.dal.dataobject.model.AiModelDO;
import org.apache.ibatis.annotations.Mapper;

import javax.annotation.Nullable;
import java.util.List;

/**
 * API 模型 Mapper
 *
 * @author fansili
 */
@Mapper
public interface AiChatMapper extends BaseMapperX<AiModelDO> {

    // 说明：原 `selectFirstByStatus(type, status)` 已删除（2026-10-12）。
    // 它只按 `ai_model.status` + `sort` 取第一条，**完全不看模型绑定的 AI 密钥是否可用**，
    // 正是「默认模型永远选中已停用密钥的那个模型」的入口。
    // 现在改由 AiModelServiceImpl#getRequiredDefaultModel 按 sort 升序遍历并跳过密钥不可用者，
    // 并复用 #selectListByStatusAndType，故此处不再需要单条取首的便捷方法。

    default PageResult<AiModelDO> selectPage(AiModelPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<AiModelDO>()
                .likeIfPresent(AiModelDO::getName, reqVO.getName())
                .eqIfPresent(AiModelDO::getModel, reqVO.getModel())
                .eqIfPresent(AiModelDO::getPlatform, reqVO.getPlatform())
                .orderByAsc(AiModelDO::getSort));
    }

    default List<AiModelDO> selectListByStatusAndType(Integer status, Integer type,
                                                      @Nullable String platform) {
        return selectList(new LambdaQueryWrapperX<AiModelDO>()
                .eq(AiModelDO::getStatus, status)
                .eq(AiModelDO::getType, type)
                .eqIfPresent(AiModelDO::getPlatform, platform)
                .orderByAsc(AiModelDO::getSort));
    }

}
