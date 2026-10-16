-- ============================================================================
--  V004__ai-role-avatars.sql
--
--  用途：给内置 AI 角色补上头像，修掉「角色仓库里图标全是裂图」
--  依赖：V001（角色的来源）
--  可重复执行：是
--
--  背景：V001 建角色时把 avatar 留成 NULL，而前端 RoleList.vue 用的是
--        <img :src="role.avatar"> 且**没有兜底**，于是 5 个公共角色全部裂图。
--
--  修复分两步（缺一不可）：
--    1) 前端：RoleList.vue 增加兜底默认图（避免以后任何空头像都裂图）
--    2) 数据：本迁移给 5 个内置角色写入**仓库自带的**头像资源
--       （fusion-ui-admin/public/ai-role/*.svg，随前端一起发布，
--        放在 public/ 下所以 dev 与生产路径一致，都是 /ai-role/xxx.svg）
--
--  注意：只更新 avatar 为空的角色，不覆盖使用者自己上传/设置过的头像。
-- ============================================================================

UPDATE `ai_chat_role` SET `avatar` = '/ai-role/write.svg'
 WHERE `name` = '写作助手' AND (`avatar` IS NULL OR `avatar` = '');
UPDATE `ai_chat_role` SET `avatar` = '/ai-role/mindmap.svg'
 WHERE `name` = '导图助手' AND (`avatar` IS NULL OR `avatar` = '');
UPDATE `ai_chat_role` SET `avatar` = '/ai-role/translate.svg'
 WHERE `name` = '翻译助手' AND (`avatar` IS NULL OR `avatar` = '');
UPDATE `ai_chat_role` SET `avatar` = '/ai-role/code.svg'
 WHERE `name` = '代码助手' AND (`avatar` IS NULL OR `avatar` = '');
UPDATE `ai_chat_role` SET `avatar` = '/ai-role/general.svg'
 WHERE `name` = '通用助手' AND (`avatar` IS NULL OR `avatar` = '');

SELECT CONCAT('empty_avatar_roles=', COUNT(*)) AS `仍无头像的角色数`
  FROM `ai_chat_role` WHERE `avatar` IS NULL OR `avatar` = '';