package com.fusion.module.mes.dal.mysql.pro.route;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.mes.controller.admin.pro.route.vo.MesProRoutePageReqVO;
import com.fusion.module.mes.dal.dataobject.pro.route.MesProRouteDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * MES 工艺路线 Mapper
 *
 */
@Mapper
public interface MesProRouteMapper extends BaseMapperX<MesProRouteDO> {

    default PageResult<MesProRouteDO> selectPage(MesProRoutePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesProRouteDO>()
                .likeIfPresent(MesProRouteDO::getCode, reqVO.getCode())
                .likeIfPresent(MesProRouteDO::getName, reqVO.getName())
                .eqIfPresent(MesProRouteDO::getStatus, reqVO.getStatus())
                .betweenIfPresent(MesProRouteDO::getCreateTime, reqVO.getCreateTime())
                .orderByDesc(MesProRouteDO::getId));
    }

    default MesProRouteDO selectByCode(String code) {
        return selectOne(MesProRouteDO::getCode, code);
    }

    default List<MesProRouteDO> selectListByStatus(Integer status) {
        return selectList(MesProRouteDO::getStatus, status);
    }

}
