package com.fusion.module.bpm.dal.mysql.definition;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.module.bpm.controller.admin.definition.vo.expression.BpmProcessExpressionPageReqVO;
import com.fusion.module.bpm.dal.dataobject.definition.BpmProcessExpressionDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * BPM 流程表达式 Mapper
 *
 */
@Mapper
public interface BpmProcessExpressionMapper extends BaseMapperX<BpmProcessExpressionDO> {

    default PageResult<BpmProcessExpressionDO> selectPage(BpmProcessExpressionPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<BpmProcessExpressionDO>()
                .likeIfPresent(BpmProcessExpressionDO::getName, reqVO.getName())
                .eqIfPresent(BpmProcessExpressionDO::getStatus, reqVO.getStatus())
                .betweenIfPresent(BpmProcessExpressionDO::getCreateTime, reqVO.getCreateTime())
                .orderByDesc(BpmProcessExpressionDO::getId));
    }

}