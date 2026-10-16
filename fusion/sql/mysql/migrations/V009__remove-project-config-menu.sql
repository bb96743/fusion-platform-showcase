-- ============================================================================
--  V009__remove-project-config-menu.sql
--
--  用途：撤销 V008 新增的「基础设施 → 项目配置」菜单（含其角色授权）
--  依赖：V008
--  可重复执行：是（纯 DELETE）
--
--  背景（项目负责人 2026-10-05 指正）：
--    Logo 上传**不该占一个后台菜单**。它属于品牌外观，应放在右上角齿轮打开的
--    「项目配置」设置抽屉里 —— 那个抽屉的标题本来就是 `t('setting.projectSetting')`。
--    前端已改为在 `Setting/components/ProjectLogo.vue` 提供上传，
--    独立页面 `views/infra/project-config/index.vue` 同步删除。
--
--    V008 已执行（在 schema_migration 里登记了 SHA-256），按「只增不改」不能改它，
--    故用本迁移撤销其数据改动。
--
--  ⚠️ 同时已从 `fusion-init.sql` 移除 V008 对应段（基线不应种下「马上要被删掉」的菜单）。
--     全新导入时 V008 仍会按顺序执行插入、随后被本迁移删除，最终结果一致。
-- ============================================================================


-- 1) 先删角色授权（外键语义上先删引用方）
DELETE FROM `system_role_menu` WHERE `menu_id` = 1000;

-- 2) 再删菜单本身
DELETE FROM `system_menu` WHERE `id` = 1000;


-- ---------------------------------------------------------------------------
-- 3) 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT('项目配置菜单残留 = ', COUNT(*), '（期望 0）') AS `自检1_菜单`
  FROM `system_menu` WHERE `id` = 1000;

SELECT CONCAT('其角色授权残留 = ', COUNT(*), '（期望 0）') AS `自检2_授权`
  FROM `system_role_menu` WHERE `menu_id` = 1000;

SELECT CONCAT('菜单总数 = ', (SELECT COUNT(*) FROM `system_menu` WHERE `deleted` = b'0'),
              ' / 超管授权 = ', (SELECT COUNT(*) FROM `system_role_menu` `rm`
                                  JOIN `system_role` `r` ON `r`.`id` = `rm`.`role_id`
                                 WHERE `r`.`code` = 'super_admin'),
              '（两者应相等，见 V005 的账面一致性约定）') AS `自检3_授权一致`;

SELECT CONCAT('孤儿授权 = ', COUNT(*), '（期望 0）') AS `自检4_孤儿授权`
  FROM `system_role_menu` `rm`
  LEFT JOIN `system_menu` `m` ON `m`.`id` = `rm`.`menu_id`
 WHERE `m`.`id` IS NULL OR `m`.`deleted` = b'1';
