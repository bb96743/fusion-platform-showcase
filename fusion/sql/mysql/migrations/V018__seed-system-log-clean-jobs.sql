-- ============================================================================
--  V018__seed-system-log-clean-jobs.sql
--
--  用途：为「system 登录日志 / 操作日志」注册定时清理任务。
--
--  为什么（system.md 8.1 P0-2）：
--    infra 侧已有 3 个清理 Job（访问日志/错误日志/任务日志），但 system 侧的
--    system_login_log / system_operate_log **没有任何清理机制** —— 两张表只增不减，
--    长期拖慢查询、膨胀备份。本迁移配套新增的 LoginLogCleanJob / OperateLogCleanJob
--    （与 infra 侧 AccessLogCleanJob 完全同构：保留 14 天、每批 100 条、@TenantIgnore）。
--
--  ⚠️ 初始状态为 INIT(0)：Quartz 的注册动作只发生在 createJob 流程
--    （schedulerManager.addJob），直接插 NORMAL 并**不会**注册调度器
--    （实测：trigger 报 "The job referenced by the trigger does not exist"）。
--    首次启用请到「基础设施 → 定时任务」界面点「开启」。
--
--  可重复执行：INSERT IGNORE（依赖主键去重）
-- ============================================================================

SET NAMES utf8mb4;

INSERT IGNORE INTO `infra_job` (`id`, `name`, `status`, `handler_name`, `handler_param`, `cron_expression`, `retry_count`, `retry_interval`, `monitor_timeout`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
VALUES (36, '登录日志清理 Job', 0, 'loginLogCleanJob', '', '0 0 0 * * ?', 0, 0, 0, 'V018', NOW(), 'V018', NOW(), b'0'),
       (37, '操作日志清理 Job', 0, 'operateLogCleanJob', '', '0 0 0 * * ?', 0, 0, 0, 'V018', NOW(), 'V018', NOW(), b'0');