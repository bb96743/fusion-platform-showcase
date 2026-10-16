package com.fusion.module.system.job.logger;

import com.fusion.framework.quartz.core.handler.JobHandler;
import com.fusion.framework.tenant.core.aop.TenantIgnore;
import com.fusion.module.system.service.logger.LoginLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;

/**
 * 物理删除 N 天前的登录日志的 Job
 *
 * 与 infra 侧 AccessLogCleanJob 同构（system 登录/操作日志此前没有任何清理任务，
 * 两张表只增不减 —— 见 docs/plans/system.md §8.1 P0-2）。
 */
@Component
@Slf4j
public class LoginLogCleanJob implements JobHandler {

    @Resource
    private LoginLogService loginLogService;

    /**
     * 清理超过（14）天的日志
     */
    private static final Integer JOB_CLEAN_RETAIN_DAY = 14;

    /**
     * 每次删除间隔的条数，如果值太高可能会造成数据库的压力过大
     */
    private static final Integer DELETE_LIMIT = 100;

    @Override
    @TenantIgnore
    public String execute(String param) {
        Integer count = loginLogService.cleanLoginLog(JOB_CLEAN_RETAIN_DAY, DELETE_LIMIT);
        log.info("[execute][定时执行清理登录日志数量 ({}) 个]", count);
        return String.format("定时执行清理登录日志数量 %s 个", count);
    }

}
