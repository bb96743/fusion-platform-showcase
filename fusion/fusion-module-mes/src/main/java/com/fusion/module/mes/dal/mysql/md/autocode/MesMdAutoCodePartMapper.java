package com.fusion.module.mes.dal.mysql.md.autocode;

import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.dal.dataobject.md.autocode.MesMdAutoCodePartDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 编码规则组成 Mapper
 *
 * @author Fusion 数智业务中台源码
 */
@Mapper
public interface MesMdAutoCodePartMapper extends BaseMapperX<MesMdAutoCodePartDO> {

    default List<MesMdAutoCodePartDO> selectListByRuleId(Long ruleId) {
        return selectList(new LambdaQueryWrapperX<MesMdAutoCodePartDO>()
                .eq(MesMdAutoCodePartDO::getRuleId, ruleId)
                .orderByAsc(MesMdAutoCodePartDO::getSort));
    }

    default List<MesMdAutoCodePartDO> selectByType(Integer type) {
        return selectList(MesMdAutoCodePartDO::getType, type);
    }

    default void deleteByRuleId(Long ruleId) {
        delete(MesMdAutoCodePartDO::getRuleId, ruleId);
    }

}
