-- ============================================================================
--  V012__rename-logo-mode-labels.sql
--
--  用途：把两条 Logo 配置的**展示文案**从「亮版/暗版」改为「深色/浅色侧边栏」
--  依赖：V010（system.logo-mode）、V011（system.logo-dark）
--  可重复执行：是（纯 UPDATE，结果幂等）
--
--  背景（为什么必须改）：
--    V010/V011 的 name 与 remark 会**显示在界面上**（「项目配置」抽屉与「基础设施 →
--    配置管理」列表）。而"亮版/暗版"两个词存在真实歧义：
--      理解A：指**图标自己的底色**（白图标=亮版）        -> 我方实现
--      理解B：指**它配的背景色**（配深色侧边栏=暗版）    -> 项目负责人的说法
--    两种理解会得出**完全相反**的标注，并且已经实际造成一次误解。
--
--    项目负责人决定：改成按「配什么颜色的侧边栏」命名 ——
--    管理员只要看自己侧边栏的颜色就能选对，不需要理解任何抽象概念。
--
--  注意：
--    · 配置**键名与值都不改**（system.logo-mode 仍为 light/dark），
--      因此后端接口、前端逻辑、既有数据全部不受影响，本迁移只动展示文案。
--    · V010/V011 已执行且受 SHA-256 校验保护（改了会让迁移工具中止），
--      故用新增迁移来修正，而不是回头修改旧文件 —— 符合"迁移只增不改"的约定。
--    · 与 `fusion-init.sql` 的种子段**内容对应**（改一处须同步另一处）。
-- ============================================================================

UPDATE `infra_config`
   SET `name`   = '项目 Logo 侧边栏配色',
       `remark` = '按侧边栏颜色选择：深色侧边栏=白色图标（默认）；浅色侧边栏=黑色图标。在「项目配置」里切换',
       `updater` = 'admin',
       `update_time` = NOW()
 WHERE `config_key` = 'system.logo-mode';

UPDATE `infra_config`
   SET `name`   = '项目 Logo（浅色侧边栏用）',
       `remark` = '黑色图标；仅当 system.logo-mode=dark 时使用。留空则使用内置黑色图标',
       `updater` = 'admin',
       `update_time` = NOW()
 WHERE `config_key` = 'system.logo-dark';


-- ---------------------------------------------------------------------------
-- 结果自检
-- ---------------------------------------------------------------------------
SELECT CONCAT(`config_key`, ' -> name=[', `name`, ']') AS `自检1_名称`
  FROM `infra_config` WHERE `config_key` IN ('system.logo-mode', 'system.logo-dark')
 ORDER BY `config_key`;

SELECT CONCAT('仍含"亮版/暗版"字样的配置行数 = ', COUNT(*), '（期望 0）') AS `自检2_旧表述已清除`
  FROM `infra_config`
 WHERE `config_key` LIKE 'system.logo%'
   AND (`name` LIKE '%亮版%' OR `name` LIKE '%暗版%'
        OR `remark` LIKE '%亮版%' OR `remark` LIKE '%暗版%');
