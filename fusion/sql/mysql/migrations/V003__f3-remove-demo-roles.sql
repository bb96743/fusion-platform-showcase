-- ============================================================================
--  V003__f3-remove-demo-roles.sql
--
--  用途：F3 公共能力改造 —— 删除**已删模块 / 演示 / 测试**留下的角色
--  依赖：V002
--  可重复执行：是（幂等 DELETE）
--
--  背景：基线里 tenant_id=1 下有 5 个角色，其中 3 个不属于本项目：
--    id=3   CRM 管理员        code=crm_admin          —— CRM 模块已删除
--    id=155 数据权限测试12     code=test-dp            —— 演示/测试角色
--    id=162 HRM团队负责人      code=hrm_team_leader    —— HRM 模块已删除；
--                              而且它的**中文名字是乱码**，正是 13.11.3 记录的
--                              「PowerShell 5.1 的 Invoke-RestMethod 把中文写成 ?」那个坑的残留
--
--  保留：id=1 超级管理员（super_admin）、id=2 普通角色（common）—— 这两个是框架必需的。
--
--  同时清理它们的授权行（system_role_menu）与用户绑定（system_user_role），
--  避免留下孤儿授权。admin 只绑定了角色 1 与 2，不受影响。
-- ============================================================================


-- 1) 授权行（先删子表）
DELETE FROM `system_role_menu`
 WHERE `role_id` IN (SELECT `id` FROM `system_role`
                      WHERE `code` IN ('crm_admin', 'test-dp', 'hrm_team_leader'));

-- 2) 用户绑定
DELETE FROM `system_user_role`
 WHERE `role_id` IN (SELECT `id` FROM `system_role`
                      WHERE `code` IN ('crm_admin', 'test-dp', 'hrm_team_leader'));

-- 3) 角色本身
DELETE FROM `system_role`
 WHERE `code` IN ('crm_admin', 'test-dp', 'hrm_team_leader');


-- 4) 复核：期望 2（超级管理员 + 普通角色）
SELECT CONCAT('role=', COUNT(*)) AS `角色总数` FROM `system_role`;
SELECT CONCAT(id, ' | ', name, ' | ', code) AS `剩余角色` FROM `system_role` ORDER BY id;
