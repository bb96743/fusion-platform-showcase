-- ============================================================================
--  V006__rename-to-fusion-platform.sql
--
--  用途：项目更名为「Fusion 数智业务中台」（Fusion = 融合：多模块 / AI 融合）
--  依赖：V002（根部门 100 已收敛为品牌名）
--  可重复执行：是（幂等 UPDATE）
--
--  背景：品牌名在数据库里出现在 4 处**功能性**位置，改名必须一起改，
--        否则「登录页租户名 ≠ 库里的租户名」之类的不一致会出现（前者在 .env，后者在此）：
--          1) system_tenant.name            —— 租户名（前端 VITE_APP_DEFAULT_LOGIN_TENANT 必须与它一致）
--          2) system_dept(id=100).name      —— 根部门名
--          3) system_oauth2_client.name     —— OAuth2 客户端展示名
--          4) system_notify_message 的模板参数（演示数据的残留文案）
--  说明：历史分析报告里的旧名**故意不改**（那是当时的记录）。
-- ============================================================================

UPDATE `system_tenant` SET `name` = 'Fusion 数智业务中台' WHERE `name` = 'Fusion 管理平台';
UPDATE `system_dept`   SET `name` = 'Fusion 数智业务中台' WHERE `id` = 100 AND `name` = 'Fusion 管理平台';
UPDATE `system_oauth2_client` SET `name` = 'Fusion 数智业务中台' WHERE `name` = 'Fusion 管理平台';
UPDATE `system_notify_message`
   SET `template_params` = REPLACE(`template_params`, 'Fusion 管理平台', 'Fusion 数智业务中台')
 WHERE `template_params` LIKE '%Fusion 管理平台%';

SELECT CONCAT('tenant=', (SELECT `name` FROM `system_tenant` WHERE `id` = 1)) AS `租户名`;
SELECT CONCAT('root_dept=', (SELECT `name` FROM `system_dept` WHERE `id` = 100)) AS `根部门`;