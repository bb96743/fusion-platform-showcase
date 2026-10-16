package com.fusion.module.mes.dal.mysql.dv.checkplan;

import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.dal.dataobject.dv.checkplan.MesDvCheckPlanSubjectDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 点检保养方案项目 Mapper
 *
 */
@Mapper
public interface MesDvCheckPlanSubjectMapper extends BaseMapperX<MesDvCheckPlanSubjectDO> {

    default List<MesDvCheckPlanSubjectDO> selectListByPlanId(Long planId) {
        return selectList(MesDvCheckPlanSubjectDO::getPlanId, planId);
    }

    default Long selectCountByPlanId(Long planId) {
        return selectCount(MesDvCheckPlanSubjectDO::getPlanId, planId);
    }

    default void deleteByPlanId(Long planId) {
        delete(new LambdaQueryWrapperX<MesDvCheckPlanSubjectDO>()
                .eq(MesDvCheckPlanSubjectDO::getPlanId, planId));
    }

    default Long selectCountBySubjectId(Long subjectId) {
        return selectCount(MesDvCheckPlanSubjectDO::getSubjectId, subjectId);
    }

    default MesDvCheckPlanSubjectDO selectByPlanIdAndSubjectId(Long planId, Long subjectId) {
        return selectOne(new LambdaQueryWrapperX<MesDvCheckPlanSubjectDO>()
                .eq(MesDvCheckPlanSubjectDO::getPlanId, planId)
                .eq(MesDvCheckPlanSubjectDO::getSubjectId, subjectId));
    }

}
