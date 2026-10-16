package com.fusion.module.system.service.logger;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.module.system.api.logger.dto.LoginLogCreateReqDTO;
import com.fusion.module.system.controller.admin.logger.vo.loginlog.LoginLogPageReqVO;
import com.fusion.module.system.dal.dataobject.logger.LoginLogDO;

import jakarta.validation.Valid;

/**
 * 登录日志 Service 接口
 */
public interface LoginLogService {

    /**
     * 获得登录日志
     *
     * @param id 编号
     * @return 登录日志
     */
    LoginLogDO getLoginLog(Long id);

    /**
     * 获得登录日志分页
     *
     * @param pageReqVO 分页条件
     * @return 登录日志分页
     */
    PageResult<LoginLogDO> getLoginLogPage(LoginLogPageReqVO pageReqVO);

    /**
     * 创建登录日志
     *
     * @param reqDTO 日志信息
     */
    void createLoginLog(@Valid LoginLogCreateReqDTO reqDTO);

    /**
     * 物理删除超过 exceedDay 天的登录日志（供定时任务调用，分页删除）
     *
     * @param exceedDay   超过多少天过期
     * @param deleteLimit 每次删除的分页条数
     * @return 本次清理的总数
     */
    Integer cleanLoginLog(Integer exceedDay, Integer deleteLimit);
}
