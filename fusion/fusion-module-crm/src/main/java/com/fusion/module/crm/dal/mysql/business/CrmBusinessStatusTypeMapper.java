package com.fusion.module.crm.dal.mysql.business;

import com.fusion.framework.common.pojo.PageParam;
import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.crm.dal.dataobject.business.CrmBusinessStatusTypeDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 商机状态组 Mapper
 *
 * @author ljlleo
 */
@Mapper
public interface CrmBusinessStatusTypeMapper extends BaseMapperX<CrmBusinessStatusTypeDO> {

    default PageResult<CrmBusinessStatusTypeDO> selectPage(PageParam reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<CrmBusinessStatusTypeDO>()
                .orderByDesc(CrmBusinessStatusTypeDO::getId));
    }

    default CrmBusinessStatusTypeDO selectByName(String name) {
        return selectOne(CrmBusinessStatusTypeDO::getName, name);
    }

}
