package com.fusion.module.mes.dal.mysql.wm.returnvendor;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.controller.admin.wm.returnvendor.vo.line.MesWmReturnVendorLinePageReqVO;
import com.fusion.module.mes.dal.dataobject.wm.returnvendor.MesWmReturnVendorLineDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 供应商退货单行 Mapper
 */
@Mapper
public interface MesWmReturnVendorLineMapper extends BaseMapperX<MesWmReturnVendorLineDO> {

    default PageResult<MesWmReturnVendorLineDO> selectPage(MesWmReturnVendorLinePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesWmReturnVendorLineDO>()
                .eqIfPresent(MesWmReturnVendorLineDO::getReturnId, reqVO.getReturnId())
                .orderByDesc(MesWmReturnVendorLineDO::getId));
    }

    default List<MesWmReturnVendorLineDO> selectListByReturnId(Long returnId) {
        return selectList(MesWmReturnVendorLineDO::getReturnId, returnId);
    }

    default void deleteByReturnId(Long returnId) {
        delete(MesWmReturnVendorLineDO::getReturnId, returnId);
    }

}
