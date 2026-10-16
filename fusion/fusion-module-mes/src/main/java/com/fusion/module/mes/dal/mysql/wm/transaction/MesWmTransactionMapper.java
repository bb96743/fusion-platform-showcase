package com.fusion.module.mes.dal.mysql.wm.transaction;

import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.module.mes.dal.dataobject.wm.transaction.MesWmTransactionDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * MES 库存事务流水 Mapper
 */
@Mapper
public interface MesWmTransactionMapper extends BaseMapperX<MesWmTransactionDO> {

}
