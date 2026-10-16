-- ============================================================================
--  V010__seed-project-logo-mode-config.sql
--
--  用途：为「项目 Logo 亮/暗版本切换」预置一条参数配置（infra_config）
--  依赖：V007（system.logo 行）
--  可重复执行：是（按 config_key 判定是否已存在）
--
--  背景：侧边栏底部(#001529)与登录页左侧层(--login-bg-color #293146)在**亮暗主题下
--        都是深色**，所以出厂必须用「亮版」图标（实测对比度 4.35:1 / 3.06:1）。
--        但若客户把侧边栏改成浅色，亮版在白底上只有 2.78:1 会发灰，
--        此时应切到「暗版」（白底 4.88:1）。本配置即为此提供一个**手动开关**。
--
--  取值为 'light' / 'dark'，空值等同于 'light'（前端兜底），
--  这样即使配置被清空也不会出现"没有 Logo"的状态。
--
--  为什么 type = 1（系统内置）：
--    与 V007 同理 —— 值可改（ConfigServiceImpl#updateConfig 不拦系统内置），
--    但行不可删（#deleteConfig 会抛 CONFIG_CAN_NOT_DELETE_SYSTEM_TYPE），
--    防止这条配置被误删导致亮暗切换失效。
--
--  为什么 visible = b'1'：
--    Logo 相关配置需要能被公开接口 /get-logo-mode 读出（登录页未登录就要用）。
--
--  与 `fusion-init.sql` 的种子段**内容对应**（改一处须同步另一处）。
-- ============================================================================

INSERT INTO `infra_config` (`id`, `category`, `type`, `name`, `config_key`, `value`, `visible`, `remark`,
                            `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT 15, '品牌', 1, '项目 Logo 亮暗版本', 'system.logo-mode', 'light', b'1',
       'light=亮版（默认，适合深色侧边栏）；dark=暗版（适合浅色侧边栏）。在「基础设施 → 项目配置」切换',
       'admin', NOW(), 'admin', NOW(), b'0'
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `infra_config` WHERE `config_key` = 'system.logo-mode');


-- ---------------------------------------------------------------------------
-- 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT('system.logo-mode 行数 = ', COUNT(*), '（期望 1）') AS `自检1_配置存在`
  FROM `infra_config` WHERE `config_key` = 'system.logo-mode';

SELECT CONCAT('type=', `type`, ' visible=', `visible` + 0, ' value=[', `value`, ']（期望 type=1 visible=1 value=light）')
       AS `自检2_取值`
  FROM `infra_config` WHERE `config_key` = 'system.logo-mode';
