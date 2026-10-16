package com.fusion.module.infra.dal.mysql.db;

import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.module.infra.dal.dataobject.db.DataSourceConfigDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 数据源配置 Mapper
 *
 */
@Mapper
public interface DataSourceConfigMapper extends BaseMapperX<DataSourceConfigDO> {
}
