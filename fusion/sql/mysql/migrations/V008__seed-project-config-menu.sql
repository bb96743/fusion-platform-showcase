-- ============================================================================
--  V008__seed-project-config-menu.sql
--
--  用途：新增「基础设施 → 项目配置」菜单（项目 Logo 上传入口）
--  依赖：V007（system.logo 配置行）
--  可重复执行：是（按 menu id / 角色菜单关联判定是否已存在）
--
--  背景：Logo 的上传入口需要一个后台页面（视图文件
--        `fusion-ui-admin/src/views/infra/project-config/index.vue`）。
--        本迁移负责**菜单与授权**，让页面能被访问到。
--
--  为什么 id 取 1000：
--    业务菜单当前占用 1~920，AUTO_INCREMENT 已到 12732（历次增删导致）。
--    这里显式指定一个**未被占用**的 id（迁移执行前已核对 id=1000 为空），
--    而不是依赖自增 —— 见 docs/plans/system.md 第 6 节「不要用 id 递增假设」。
--
--  为什么同时给 super_admin 补授权：
--    V005 已把超管的授权补成「当时的菜单全集」。新增菜单后若不补，
--    账面会变成「授权 297 / 菜单 298」。超管实际靠角色码绕过授权表（见 system.md 3.2），
--    功能上不受影响，但为了保持 V005 建立的**账面一致性**，这里一并补上。
--
--  ⚠️ 未授权给 `common`（普通角色）：这是管理级配置页，按最小权限原则默认不给。
--     将来定义角色矩阵时若需要，再单独加授权。
--
--  与 `fusion-init.sql` 的对应段**内容对应**（改一处须同步另一处）。
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1) 菜单：基础设施(2) → 项目配置
--    字段取值对齐同级菜单「配置管理」(id=10)：type=2、status=0、
--    visible/keep_alive/always_show 均为 b'1'；sort=9 排在配置管理(8)与监控中心(10)之间。
-- ---------------------------------------------------------------------------
INSERT INTO `system_menu` (`id`, `name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`,
                           `component`, `component_name`, `status`, `visible`, `keep_alive`,
                           `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT 1000, '项目配置', '', 2, 9, 2, 'project-config', 'ep:setting',
       'infra/project-config/index', 'InfraProjectConfig', 0, b'1', b'1',
       b'1', 'V008', NOW(), 'V008', NOW(), b'0'
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `system_menu` WHERE `id` = 1000);


-- ---------------------------------------------------------------------------
-- 2) 授权给超级管理员
-- ---------------------------------------------------------------------------
INSERT INTO `system_role_menu` (`role_id`, `menu_id`, `creator`, `create_time`, `updater`,
                                `update_time`, `deleted`, `tenant_id`)
SELECT `r`.`id`, 1000, 'V008', NOW(), 'V008', NOW(), b'0', 1
  FROM `system_role` `r`
 WHERE `r`.`code` = 'super_admin'
   AND `r`.`deleted` = b'0'
   AND NOT EXISTS (SELECT 1 FROM `system_role_menu` `rm`
                    WHERE `rm`.`role_id` = `r`.`id` AND `rm`.`menu_id` = 1000);


-- ---------------------------------------------------------------------------
-- 3) 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT('项目配置菜单 = ', COUNT(*), '（期望 1）') AS `自检1_菜单`
  FROM `system_menu` WHERE `id` = 1000;

SELECT CONCAT('菜单总数 = ', (SELECT COUNT(*) FROM `system_menu` WHERE `deleted` = b'0'),
              ' / 超管授权 = ', (SELECT COUNT(*) FROM `system_role_menu` `rm`
                                  JOIN `system_role` `r` ON `r`.`id` = `rm`.`role_id`
                                 WHERE `r`.`code` = 'super_admin'),
              '（两者应相等，见 V005 的账面一致性约定）') AS `自检2_授权一致`;
