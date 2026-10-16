-- ============================================================================
--  【执行顺序 ⑥ · 可选】AI 大模型（DeepSeek）初始配置
--
--  前置：`ai_api_key` / `ai_model` 两张表已存在（由 ③ fusion-modules.sql 创建）
--  可重复执行：是（用 NOT EXISTS 判重；不会产生重复行，也不会覆盖已有配置）
--
--  什么时候需要它
--    只有「从零重建数据库、希望一步到位配好一个默认模型」时才需要。
--    日常增删改模型与密钥 **请直接用管理后台**：
--      AI 大模型 → API 密钥 / 模型管理
--
--  ⚠️ 本文件不含任何真实密钥。`sk-REPLACE_WITH_YOUR_OWN_KEY` 是占位符，
--     直接执行不会造成损坏：在没有命中现有配置时会插入一条占位密钥，
--     此时 AI 对话会返回「大模型返回 401，API 密钥无效」—— 这是预期行为。
--     **不要把真实密钥写进本文件再提交到版本库**（本项目已因此踩过一次坑，
--     见 需求分析文档.md 13.15 C5）。
--
--  ⚠️ 本文件刻意 **不写 `ai_chat_role`**。聊天角色由
--     `_tooling/12-db-seed-ai-roles.sql` 负责，其中「写作助手」「导图助手」
--     的名字必须与 `AiChatRoleEnum` 完全一致；在这里插角色会覆盖它们，
--     直接导致 **AI 写作 / AI 思维导图失效**（见 13.15 C6）。
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1) API 密钥
--    platform 必须与 AiPlatformEnum 的取值一致：DeepSeek / OpenAI / Ollama ...
--    url 留空则用该平台的官方地址；自建或中转服务在此填写
-- ---------------------------------------------------------------------------
INSERT INTO `ai_api_key`
    (`name`, `api_key`, `platform`, `url`, `status`, `creator`, `deleted`, `tenant_id`)
SELECT 'DeepSeek', 'sk-REPLACE_WITH_YOUR_OWN_KEY', 'DeepSeek', 'https://api.deepseek.com',
       0, '1', b'0', 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `ai_api_key` WHERE `platform` = 'DeepSeek' AND `deleted` = b'0'
);


-- ---------------------------------------------------------------------------
-- 2) 模型
--    type=1 对话（见 AiModelTypeEnum）/ status=0 开启 / sort 最小者即默认模型
--    model 取值以平台文档为准（如 deepseek-chat / deepseek-reasoner）
-- ---------------------------------------------------------------------------
INSERT INTO `ai_model`
    (`key_id`, `name`, `model`, `platform`, `type`, `sort`, `status`,
     `temperature`, `max_tokens`, `max_contexts`, `creator`, `deleted`, `tenant_id`)
SELECT k.`id`, 'DeepSeek Chat', 'deepseek-chat', 'DeepSeek', 1, 0, 0,
       0.7, 8192, 10, '1', b'0', 0
FROM `ai_api_key` k
WHERE k.`platform` = 'DeepSeek'
  AND k.`deleted` = b'0'
  AND NOT EXISTS (
      SELECT 1 FROM `ai_model` m
      WHERE m.`platform` = 'DeepSeek' AND m.`model` = 'deepseek-chat' AND m.`deleted` = b'0'
  );


-- ---------------------------------------------------------------------------
-- 3) 零成本本地替代方案：Ollama
--    装好 Ollama 并 `ollama pull qwen2.5` 后取消下面注释即可（无需任何密钥）
--    （application-local.yaml 已预置 spring.ai.ollama.base-url）
-- ---------------------------------------------------------------------------
-- INSERT INTO `ai_api_key` (`name`, `api_key`, `platform`, `url`, `status`, `creator`, `deleted`, `tenant_id`)
-- SELECT 'Ollama 本地', '', 'Ollama', 'http://127.0.0.1:11434', 0, '1', b'0', 0
-- FROM DUAL
-- WHERE NOT EXISTS (SELECT 1 FROM `ai_api_key` WHERE `platform` = 'Ollama' AND `deleted` = b'0');
