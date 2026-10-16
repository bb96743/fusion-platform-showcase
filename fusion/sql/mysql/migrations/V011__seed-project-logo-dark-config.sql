-- ============================================================================
--  V011__seed-project-logo-dark-config.sql
--
--  用途：为「项目 Logo 暗版上传槽」预置一条参数配置（infra_config）
--  依赖：V007（system.logo）、V010（system.logo-mode）
--  可重复执行：是（按 config_key 判定是否已存在）
--
--  为什么需要独立的暗版槽位：
--    亮暗两个版本是**两张不同的图**。若共用一个 system.logo，
--    切换版本时只能显示同一张图，开关就失去意义。
--    因此两个版本各有一个上传槽，`system.logo-mode` 决定当前用哪个：
--      mode=light -> 取 system.logo，留空则回退内置亮版 logo.png
--      mode=dark  -> 取 system.logo-dark，留空则回退内置暗版 logo-dark.png
--
--  为什么 type = 1（系统内置）：
--    与 V007/V010 同理 —— 值可改（#updateConfig 不拦系统内置），
--    但行不可删（#deleteConfig 抛 CONFIG_CAN_NOT_DELETE_SYSTEM_TYPE），
--    防止槽位被误删导致「上传了却没地方存」。
--
--  与 `fusion-init.sql` 的种子段**内容对应**（改一处须同步另一处）。
-- ============================================================================

INSERT INTO `infra_config` (`id`, `category`, `type`, `name`, `config_key`, `value`, `visible`, `remark`,
                            `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT 16, '品牌', 1, '项目 Logo（暗版）', 'system.logo-dark', '', b'1',
       '暗版图标；仅当 system.logo-mode=dark 时使用。留空则使用内置暗版图片',
       'admin', NOW(), 'admin', NOW(), b'0'
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `infra_config` WHERE `config_key` = 'system.logo-dark');


-- ---------------------------------------------------------------------------
-- 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT('system.logo-dark 行数 = ', COUNT(*), '（期望 1）') AS `自检1_配置存在`
  FROM `infra_config` WHERE `config_key` = 'system.logo-dark';

SELECT CONCAT('type=', `type`, ' visible=', `visible` + 0, ' value=[', `value`, ']（期望 type=1 visible=1 value 空）')
       AS `自检2_取值`
  FROM `infra_config` WHERE `config_key` = 'system.logo-dark';
