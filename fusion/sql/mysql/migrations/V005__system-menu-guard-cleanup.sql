-- ============================================================================
--  V005__system-menu-guard-cleanup.sql
--
--  用途：system 模块「菜单权限守卫 + 品牌/演示残留」清理
--  依赖：基线（fusion-init.sql / fusion-modules.sql / quartz.sql）+ V001 ~ V004
--  可重复执行：是（全部为幂等的 DELETE / UPDATE）
--
--  本迁移做四件事（都属于「不依赖业务输入、方向明确、且越早做越安全」的收口）：
--    1) 删除**孤儿角色授权**：system_role_menu 里指向「已不存在菜单」的 48 行
--    2) 修正旧品牌名残留：ai_chat_role 的提示词示例、system_notice 的公告标题
--    3) 删除上游演示/测试残留：SSO 演示客户端、会员类短信模板、演示公告内容
--    4) 补一个**防呆护栏**：给超级管理员角色补回「本系统全部有效菜单」的授权
--       —— 这是 14.5 风险「动权限容易把自己锁在外面」的直接对策
--
--  ⚠️ 与 `fusion-init.sql` 末尾的清理段**内容对应**（改一处须同步另一处）：
--     本文件用于「已经建好的库」，那段用于「全新导入」。
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1) 孤儿角色授权清理
--
--    现状（2026-10-04 实测）：system_role_menu 共 250 行，其中 **48 行**指向的 menu_id
--    在 system_menu 里**根本不存在**（1679/1684/1724~1734/1842~1854 等）。
--    这些 id 在基线 fusion-init.sql 里也搜不到 —— 是上游演示数据 + 历次清理留下的垃圾。
--
--    危害：菜单树接口按 menu_id 关联渲染，孤儿行会被静默丢弃；
--          但**授权数量统计会虚高**（普通角色显示 225、实际有效只有 201），
--          排查「用户为什么看不到某个菜单」时会被这 24 行的差值误导。
--
--    本删除与授权数量无关：孤儿行本来就不产生任何权限，删掉只是让账面与事实一致。
-- ---------------------------------------------------------------------------
DELETE `rm`
  FROM `system_role_menu` `rm`
  LEFT JOIN `system_menu` `m` ON `m`.`id` = `rm`.`menu_id`
 WHERE `m`.`id` IS NULL
    OR `m`.`deleted` = b'1';


-- ---------------------------------------------------------------------------
-- 2) 旧品牌名残留（「Fusion 管理平台」→「Fusion 数智业务中台」）
--
--    V006 把品牌名改到了 4 处**功能性**位置（租户名 / 根部门 / OAuth2 客户端 / 站内信模板参数），
--    但漏了两处**用户可见文本**（2026-10-04 全库 57 表全文本列扫描发现，见 docs/plans/system.md）：
--      a) ai_chat_role(id=2 导图助手) 的 system_message —— 提示词里给 AI 的**输出示例**写着旧名，
--         会让「思维导图助手」生成的导图一级标题带着旧品牌名
--      b) system_notice(id=1) 的 title —— 公告标题，后台首页会直接显示
-- ---------------------------------------------------------------------------
UPDATE `ai_chat_role`
   SET `system_message` = REPLACE(`system_message`, 'Fusion 管理平台', 'Fusion 数智业务中台')
 WHERE `system_message` LIKE '%Fusion 管理平台%';

UPDATE `system_notice`
   SET `title` = REPLACE(`title`, 'Fusion 管理平台', 'Fusion 数智业务中台')
 WHERE `title` LIKE '%Fusion 管理平台%';


-- ---------------------------------------------------------------------------
-- 3) 上游演示 / 测试残留
-- ---------------------------------------------------------------------------

-- 3.1) SSO 演示 OAuth2 客户端
--      上游教程用的三个演示客户端：client_id = test / fusion-sso-demo-by-code / fusion-sso-demo-by-password。
--      名称直接就是教程标题（「基于授权码模式，如何实现 SSO 单点登录？」）。
--      保留 default（id=1），它是 front-end 正常登录要用的那一个。
--      ⚠️ 不要按 name 删除：V006 已把 default 的名字改成了「Fusion 数智业务中台」。
DELETE FROM `system_oauth2_client`
 WHERE `client_id` IN ('test', 'fusion-sso-demo-by-code', 'fusion-sso-demo-by-password');

-- 3.2) 会员（member）类短信模板
--      这四条属于**已删除的 member 模块**（会员用户改手机 / 改密码 / 重置密码）与
--      「前台用户」概念，本项目没有前台会员体系，永远不会被触发。
--      ⚠️ 不按名字里的「会员」二字删除，而是**按 code 精确删除**，避免误伤。
DELETE FROM `system_sms_template`
 WHERE `code` IN ('user-update-mobile', 'user-update-password', 'user-reset-password', 'user-sms-login');

-- 3.3) 演示公告正文
--      system_notice(id=1) 的正文是上游的占位垃圾（`<p>新版本内容133222</p>`）。
--      标题已在第 2 节改成自有品牌名，正文保留原样只会让人以为系统出错了。
--      这里改成一句可读的初始公告；若不需要公告，可直接把 status 置为草稿。
UPDATE `system_notice`
   SET `content` = '<p>欢迎使用 Fusion 数智业务中台。可在「系统管理 - 通知公告」中修改或删除本公告。</p>'
 WHERE `id` = 1
   AND `content` LIKE '%133222%';


-- ---------------------------------------------------------------------------
-- 4) 防呆护栏：超级管理员角色补全授权
--
--    为什么加这一段：第 1 节删掉了 48 行孤儿授权后，**super_admin 的授权会变成 0 行**
--    （它的 24 行恰好全是孤儿）。super_admin 目前靠 TenantContextHolder 里的
--    「租户管理员角色码」判断跳过权限校验，所以**不会因此失去访问能力**；
--    但「超管授权数为 0」这个状态本身是反直觉的：一旦将来启用租户管理员码配置、
--    或有人在「角色管理」里点了保存，超管就真的可能被锁在外面（14.5 已把这个列为风险）。
--
--    这里按「全部有效菜单」补全，使超级管理员的授权始终等于菜单全集。
--    幂等：INSERT ... SELECT ... WHERE NOT EXISTS。
-- ---------------------------------------------------------------------------
INSERT INTO `system_role_menu` (`role_id`, `menu_id`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT `r`.`id`, `m`.`id`, 'V005', NOW(), 'V005', NOW(), b'0', 1
  FROM `system_role` `r`
  JOIN `system_menu` `m` ON `m`.`deleted` = b'0'
 WHERE `r`.`code` = 'super_admin'
   AND `r`.`deleted` = b'0'
   AND NOT EXISTS (
         SELECT 1 FROM `system_role_menu` `rm`
          WHERE `rm`.`role_id` = `r`.`id`
            AND `rm`.`menu_id` = `m`.`id`
       );


-- ---------------------------------------------------------------------------
-- 5) 结果自检（迁移执行器会打印这几个 SELECT 的结果）
-- ---------------------------------------------------------------------------
SELECT CONCAT('孤儿角色授权 = ', COUNT(*), '（期望 0）') AS `自检1_孤儿授权`
  FROM `system_role_menu` `rm`
  LEFT JOIN `system_menu` `m` ON `m`.`id` = `rm`.`menu_id`
 WHERE `m`.`id` IS NULL OR `m`.`deleted` = b'1';

SELECT CONCAT('旧品牌名残留 = ',
              (SELECT COUNT(*) FROM `ai_chat_role` WHERE `system_message` LIKE '%Fusion 管理平台%')
            + (SELECT COUNT(*) FROM `system_notice` WHERE `title` LIKE '%Fusion 管理平台%'),
              '（期望 0）') AS `自检2_旧品牌名`;

SELECT CONCAT('super_admin 授权数 = ', COUNT(*), '（期望 = 有效菜单数）') AS `自检3_超管授权`
  FROM `system_role_menu` `rm` JOIN `system_role` `r` ON `r`.`id` = `rm`.`role_id`
 WHERE `r`.`code` = 'super_admin';

SELECT CONCAT('有效菜单数 = ', COUNT(*)) AS `自检4_菜单总数` FROM `system_menu` WHERE `deleted` = b'0';
