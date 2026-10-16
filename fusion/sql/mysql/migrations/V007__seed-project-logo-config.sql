-- ============================================================================
--  V007__seed-project-logo-config.sql
--
--  用途：为「项目 Logo 可上传」功能预置一条参数配置（infra_config）
--  依赖：基线（fusion-init.sql）
--  可重复执行：是（按 config_key 判定是否已存在）
--
--  背景：侧边栏与登录页此前**硬编码**引用打包资源 `@/assets/imgs/logo.png`，
--        换 Logo 必须改文件并重新构建发版。本迁移预置一个配置键，
--        让 Logo 可以在后台「基础设施 → 项目配置」里上传替换，运行时生效。
--
--  为什么 type = 1（系统内置）：
--    · ConfigServiceImpl#updateConfig **不拦**系统内置配置 —— 所以「上传后写值」没问题；
--    · 但 #deleteConfig / #deleteConfigList **会拦**（CONFIG_CAN_NOT_DELETE_SYSTEM_TYPE）——
--      正好防止这条配置被误删导致 Logo 功能失效。
--    即：值可改、行不可删，是我们想要的语义。
--
--  为什么 visible = b'1'：
--    ConfigController#getConfigKey 对 visible=false 的配置会抛
--    CONFIG_GET_VALUE_ERROR_IF_VISIBLE；Logo 需要能读出来。
--    （公开接口 /get-logo 只读这一个硬编码 key，不受此限制影响，但保持一致更好。）
--
--  与 `fusion-init.sql` 的清理/种子段**内容对应**（改一处须同步另一处）。
-- ============================================================================

INSERT INTO `infra_config` (`id`, `category`, `type`, `name`, `config_key`, `value`, `visible`, `remark`,
                            `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT 14, '品牌', 1, '项目 Logo', 'system.logo', '', b'1',
       '侧边栏与登录页共用；留空则使用内置图片。在「基础设施 → 项目配置」上传',
       'admin', NOW(), 'admin', NOW(), b'0'
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `infra_config` WHERE `config_key` = 'system.logo');


-- ---------------------------------------------------------------------------
-- 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT('system.logo 行数 = ', COUNT(*), '（期望 1）') AS `自检1_配置存在`
  FROM `infra_config` WHERE `config_key` = 'system.logo';

SELECT CONCAT('type=', `type`, ' visible=', `visible` + 0, ' value=[', `value`, ']（期望 type=1 visible=1 value 空）')
       AS `自检2_取值`
  FROM `infra_config` WHERE `config_key` = 'system.logo';
