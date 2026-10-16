package com.fusion.module.mes.dal.mysql.dv.repair;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.controller.admin.dv.repair.vo.line.MesDvRepairLinePageReqVO;
import com.fusion.module.mes.dal.dataobject.dv.repair.MesDvRepairLineDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 维修工单行 Mapper
 *
 */
@Mapper
public interface MesDvRepairLineMapper extends BaseMapperX<MesDvRepairLineDO> {

    default PageResult<MesDvRepairLineDO> selectPage(MesDvRepairLinePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesDvRepairLineDO>()
                .eqIfPresent(MesDvRepairLineDO::getRepairId, reqVO.getRepairId())
                .orderByDesc(MesDvRepairLineDO::getId));
    }

    default List<MesDvRepairLineDO> selectListByRepairId(Long repairId) {
        return selectList(MesDvRepairLineDO::getRepairId, repairId);
    }

    default int deleteByRepairId(Long repairId) {
        return delete(MesDvRepairLineDO::getRepairId, repairId);
    }

}
