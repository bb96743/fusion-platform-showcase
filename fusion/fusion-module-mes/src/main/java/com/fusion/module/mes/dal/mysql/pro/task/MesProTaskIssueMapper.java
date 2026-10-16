package com.fusion.module.mes.dal.mysql.pro.task;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.controller.admin.pro.task.vo.MesProTaskIssuePageReqVO;
import com.fusion.module.mes.dal.dataobject.pro.task.MesProTaskIssueDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 生产任务投料 Mapper
 *
 */
@Mapper
public interface MesProTaskIssueMapper extends BaseMapperX<MesProTaskIssueDO> {

    default PageResult<MesProTaskIssueDO> selectPage(MesProTaskIssuePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesProTaskIssueDO>()
                .eqIfPresent(MesProTaskIssueDO::getTaskId, reqVO.getTaskId())
                .eqIfPresent(MesProTaskIssueDO::getWorkOrderId, reqVO.getWorkOrderId())
                .eqIfPresent(MesProTaskIssueDO::getItemId, reqVO.getItemId())
                .eqIfPresent(MesProTaskIssueDO::getSourceDocType, reqVO.getSourceDocType())
                .betweenIfPresent(MesProTaskIssueDO::getCreateTime, reqVO.getCreateTime())
                .orderByDesc(MesProTaskIssueDO::getId));
    }

    default Long selectCountByUnitMeasureId(Long unitMeasureId) {
        return selectCount(MesProTaskIssueDO::getUnitMeasureId, unitMeasureId);
    }

    default List<MesProTaskIssueDO> selectListByTaskId(Long taskId) {
        return selectList(new LambdaQueryWrapperX<MesProTaskIssueDO>()
                .eq(MesProTaskIssueDO::getTaskId, taskId)
                .orderByDesc(MesProTaskIssueDO::getId));
    }

}
