-- ============================================================================
--  V002__f3-system-infra-cleanup.sql
--
--  用途：F3 公共能力改造 —— system / infra 模块的**上游遗留收敛**
--  依赖：基线（fusion-init.sql / fusion-modules.sql / quartz.sql）+ V001
--  可重复执行：是（全部为幂等的 DELETE / UPDATE）
--
--  本迁移做四件事：
--    1) 组织架构收敛：把上游演示组织树（总公司 / 长沙分公司 / 一堆部门）
--       收敛成「根部门 + 总部」，避免新项目一上手看到别人的组织
--    2) 清掉演示岗位、演示公告、infra_config 的垃圾行与**弱默认初始口令**
--    3) 删除**已删模块**的字典（236 个类型 / 1113 条数据）—— 那些模块的代码已经不在仓库里，
--       这些字典永远不会被读到，只会淹没真正的字典
--    4) 关闭多租户的「配套数据动作」：隐藏租户管理菜单（保留数据，随时可逆）
--
--  ⚠️ 与 `fusion-init.sql` 末尾的清理段**内容对应**（改一处须同步另一处）：
--     本文件用于「已经建好的库」，那段用于「全新导入」。
--  ⚠️ 多租户的**开关**是配置项（fusion.tenant.enable=false），不在本迁移里；
--     见 需求分析文档.md 14.8 D3 与 14.12。
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1) 组织架构：收敛为「根部门（100）+ 总部（103）」
--    基线里的 101 总公司 / 102 长沙分公司 / 104~109 / 112 / 113 / 116 / 117 全是上游演示数据，
--    其中 116/117「某子部门」是纯测试行。
--    admin（id=1）的 dept_id = 103，因此必须保留 103，只把它的父级挂到根部门。
-- ---------------------------------------------------------------------------
DELETE FROM `system_dept` WHERE `id` NOT IN (100, 103);
UPDATE `system_dept` SET `name` = 'Fusion 管理平台', `parent_id` = 0,   `sort` = 0 WHERE `id` = 100;
UPDATE `system_dept` SET `name` = '总部',            `parent_id` = 100, `sort` = 1 WHERE `id` = 103;


-- ---------------------------------------------------------------------------
-- 2) 岗位：删掉演示用的「测试」岗位（code=test），并清掉指向它的授权
-- ---------------------------------------------------------------------------
DELETE FROM `system_user_post` WHERE `post_id` IN (SELECT `id` FROM `system_post` WHERE `code` = 'test');
DELETE FROM `system_post` WHERE `code` = 'test';
-- admin 的 post_ids 里引用了不存在的岗位（[1,2]，而岗位表里没有 id=1/2），一并清空
UPDATE `system_users` SET `post_ids` = '[]' WHERE `id` = 1;


-- ---------------------------------------------------------------------------
-- 3) 公告：删除上游遗留的 2018 年演示维护通知
-- ---------------------------------------------------------------------------
DELETE FROM `system_notice` WHERE `title` LIKE '%维护通知%';


-- ---------------------------------------------------------------------------
-- 4) infra_config：垃圾测试行 + 弱默认初始口令
--    `system.user.init-password` 是「Excel 导入用户」时的初始口令
--    （AdminUserServiceImpl.USER_INIT_PASSWORD_KEY），值为 123456 属于弱默认口令，
--    改为占位符，由 `_runtime\init-db.ps1` 在首次建库时生成真实值
--    （与管理员口令同一套做法，见 14.11.2）。
--    url.* 四项已是空值，无需处理。
-- ---------------------------------------------------------------------------
DELETE FROM `infra_config` WHERE `category` = 'test2' OR `config_key` = 'test4';
UPDATE `infra_config` SET `value` = 'REPLACE_WITH_YOUR_OWN_INIT_PASSWORD'
 WHERE `config_key` = 'system.user.init-password';


-- ---------------------------------------------------------------------------
-- 5) 字典：删除已删模块的字典类型与字典数据
--    前缀对应已删除的模块：crm / erp / mall / trade / promotion / member /
--    pay / mp / iot / mes / wms / hrm / fms / pms / oa / im / cms。
--    保留 system_ / infra_ / bpm_ / ai_ / report_ 等在用模块的字典。
--    `crm_admin`（角色编码）与 `oa_leave`（流程标识）是代码里的常量名，
--    与字典无关，但为稳妥起见显式排除。
-- ---------------------------------------------------------------------------
DELETE FROM `system_dict_data`
 WHERE `dict_type` REGEXP '^(crm|erp|mall|trade|promotion|member|pay|mp|iot|mes|wms|hrm|fms|pms|oa|im|cms)_'
   AND `dict_type` NOT IN ('crm_admin', 'oa_leave');

DELETE FROM `system_dict_type`
 WHERE `type` REGEXP '^(crm|erp|mall|trade|promotion|member|pay|mp|iot|mes|wms|hrm|fms|pms|oa|im|cms)_'
   AND `type` NOT IN ('crm_admin', 'oa_leave');


-- ---------------------------------------------------------------------------
-- 6) 代码生成：只保留 Vue3 + Element Plus 模板族
--    仓库里已删掉其余 6 族模板（vue / vue3_vben / vue3_vben5_* / vue3_admin_uniapp），
--    这里同步把「前端类型」字典裁到只剩 20，避免有人在界面上选到不存在的族。
--    与 application.yaml 的 fusion.codegen.front-type=20 一致。
-- ---------------------------------------------------------------------------
DELETE FROM `system_dict_data` WHERE `dict_type` = 'infra_codegen_front_type' AND `value` <> '20';


-- ---------------------------------------------------------------------------
-- 7) 多租户关闭的配套动作：隐藏「租户管理」菜单
--    `visible = b'1'` 表示可见，b'0' 表示隐藏；隐藏父菜单即隐藏整棵子树。
--    只隐藏、不删除 —— 以后要恢复多租户，把 visible 改回 b'1' 即可。
-- ---------------------------------------------------------------------------
UPDATE `system_menu` SET `visible` = b'0' WHERE `id` = 181;


-- ---------------------------------------------------------------------------
-- 8) 复核
-- ---------------------------------------------------------------------------
SELECT CONCAT('dept=',       (SELECT COUNT(*) FROM `system_dept`))       AS `部门`;
SELECT CONCAT('post=',       (SELECT COUNT(*) FROM `system_post`))       AS `岗位`;
SELECT CONCAT('notice=',     (SELECT COUNT(*) FROM `system_notice`))     AS `公告`;
SELECT CONCAT('dict_type=',  (SELECT COUNT(*) FROM `system_dict_type`))  AS `字典类型`;
SELECT CONCAT('dict_data=',  (SELECT COUNT(*) FROM `system_dict_data`))  AS `字典数据`;
SELECT CONCAT('menu=',       (SELECT COUNT(*) FROM `system_menu`))       AS `菜单`;
SELECT CONCAT('init_pwd_is_placeholder=',
       IF((SELECT `value` FROM `infra_config` WHERE `config_key` = 'system.user.init-password')
          = 'REPLACE_WITH_YOUR_OWN_INIT_PASSWORD', 'YES', 'NO'))        AS `初始口令占位`;
SELECT CONCAT('tenant_menu_visible=',
       (SELECT `visible` + 0 FROM `system_menu` WHERE `id` = 181))       AS `租户菜单可见性`;
