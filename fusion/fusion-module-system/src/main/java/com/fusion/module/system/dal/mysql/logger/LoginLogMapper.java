package com.fusion.module.system.dal.mysql.logger;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.mybatis.core.mapper.BaseMapperX;
import com.fusion.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.fusion.module.system.controller.admin.logger.vo.loginlog.LoginLogPageReqVO;
import com.fusion.module.system.dal.dataobject.logger.LoginLogDO;
import com.fusion.module.system.enums.logger.LoginResultEnum;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface LoginLogMapper extends BaseMapperX<LoginLogDO> {

    default PageResult<LoginLogDO> selectPage(LoginLogPageReqVO reqVO) {
        LambdaQueryWrapperX<LoginLogDO> query = new LambdaQueryWrapperX<LoginLogDO>()
                .likeIfPresent(LoginLogDO::getUserIp, reqVO.getUserIp())
                .likeIfPresent(LoginLogDO::getUsername, reqVO.getUsername())
                .betweenIfPresent(LoginLogDO::getCreateTime, reqVO.getCreateTime());
        if (Boolean.TRUE.equals(reqVO.getStatus())) {
            query.eq(LoginLogDO::getResult, LoginResultEnum.SUCCESS.getResult());
        } else if (Boolean.FALSE.equals(reqVO.getStatus())) {
            query.gt(LoginLogDO::getResult, LoginResultEnum.SUCCESS.getResult());
        }
        query.orderByDesc(LoginLogDO::getId); // 降序
        return selectPage(reqVO, query);
    }

    /**
     * 物理删除早于指定时间的日志（分页删除，避免单次锁表过大）。
     * 写法与 infra 侧 ApiAccessLogMapper#deleteByCreateTimeLt 完全同构 —— 见 V018 的系统日志清理。
     */
    @Delete("DELETE FROM system_login_log WHERE create_time < #{createTime} LIMIT #{limit}")
    Integer deleteByCreateTimeLt(@Param("createTime") LocalDateTime createTime, @Param("limit") Integer limit);

}
