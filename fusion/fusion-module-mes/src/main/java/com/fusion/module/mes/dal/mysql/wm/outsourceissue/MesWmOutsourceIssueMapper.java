package com.fusion.module.mes.dal.mysql.wm.outsourceissue;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.controller.admin.wm.outsourceissue.vo.MesWmOutsourceIssuePageReqVO;
import com.fusion.module.mes.dal.dataobject.wm.outsourceissue.MesWmOutsourceIssueDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * MES 外协发料单 Mapper
 *
 */
@Mapper
public interface MesWmOutsourceIssueMapper extends BaseMapperX<MesWmOutsourceIssueDO> {

    default PageResult<MesWmOutsourceIssueDO> selectPage(MesWmOutsourceIssuePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesWmOutsourceIssueDO>()
                .likeIfPresent(MesWmOutsourceIssueDO::getCode, reqVO.getCode())
                .likeIfPresent(MesWmOutsourceIssueDO::getName, reqVO.getName())
                .eqIfPresent(MesWmOutsourceIssueDO::getVendorId, reqVO.getVendorId())
                .eqIfPresent(MesWmOutsourceIssueDO::getWorkOrderId, reqVO.getWorkOrderId())
                .betweenIfPresent(MesWmOutsourceIssueDO::getIssueDate, reqVO.getIssueDate())
                .orderByDesc(MesWmOutsourceIssueDO::getId));
    }

    default MesWmOutsourceIssueDO selectByCode(String code) {
        return selectOne(MesWmOutsourceIssueDO::getCode, code);
    }

    default Long selectCountByVendorId(Long vendorId) {
        return selectCount(MesWmOutsourceIssueDO::getVendorId, vendorId);
    }

}
