-- ============================================================================
--  V017__disable-open-registration.sql
--
--  用途：关闭「开放注册」（system.user.register-enabled = false）。
--
--  为什么（system.md §8.1 P0-1，安全）：
--    `POST /admin-api/system/auth/register` 标注了 @PermitAll（免登录），
--    只靠该配置开关判断，而上游默认值是 **true** —— 任何能访问后端的人
--    都可以批量注册账号（仅受租户账号数上限约束）。已核实注册出的账号
--    不绑定任何角色，但"任人注册"本身不可接受。
--
--  确有自助注册需求时：把本配置改回 true，并配合验证码/邀请制。
--
--  可重复执行：是（纯 UPDATE，幂等）
-- ============================================================================

SET NAMES utf8mb4;

UPDATE `infra_config`
   SET `value` = 'false', `update_time` = NOW()
 WHERE `config_key` = 'system.user.register-enabled';

-- 自检
SELECT IF(`value` = 'false', 'OK: 开放注册已关闭', 'FAIL: 仍为开启') AS `自检_注册开关`
  FROM `infra_config` WHERE `config_key` = 'system.user.register-enabled';
