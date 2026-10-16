-- ============================================================================
-- Fusion —— 工作流(bpm) / AI / 报表(report) 模块建表语句
--
-- 说明：
--   1. 本文件由 _tooling\15-generate-module-ddl.ps1 依据各模块的 DO 类自动生成。
--      上游仓库自 v1.8.0 起不再随 dump 发布这三个模块的 DDL（改为文档站单独提供），
--      故以 DO 类为事实来源生成；每个 DO 字段都有对应列（可用 16-verify-module-ddl.ps1 复核）。
--   2. 列类型/长度按通用惯例推断，与上游官方脚本可能存在长度差异（不影响功能）。
--   3. 不包含 Flowable 引擎自身的 ACT_* / FLW_* 表 —— 那些由引擎在启动时自动创建
--      （flowable.database-schema-update=true）。
--   4. 不包含积木报表(JimuReport)自带表 —— 需要其官方脚本 sql/jimureport.*.create.sql。
--   5. 执行方式：mysql -u root -p fusion < fusion-modules.sql
-- ============================================================================

SET NAMES utf8mb4;

-- ----------------------------
-- Table structure for ai_api_key  [ai]  来源：AiApiKeyDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_api_key`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `api_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密钥',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API 地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI API 秘钥';

-- ----------------------------
-- Table structure for ai_chat_conversation  [ai]  来源：AiChatConversationDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_chat_conversation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID 编号，自增',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对话标题',
  `pinned` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否置顶',
  `pinned_time` datetime NULL DEFAULT NULL COMMENT '置顶时间',
  `role_id` bigint NOT NULL DEFAULT 0 COMMENT '角色编号',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型标志',
  `system_message` text NULL COMMENT '角色设定',
  `temperature` double NOT NULL DEFAULT 0 COMMENT '温度参数',
  `max_tokens` int NOT NULL DEFAULT 0 COMMENT '单条回复的最大 Token 数量',
  `max_contexts` int NOT NULL DEFAULT 0 COMMENT '上下文的最大 Message 数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_role_id` (`role_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI Chat 对话';

-- ----------------------------
-- Table structure for ai_chat_message  [ai]  来源：AiChatMessageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_chat_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，作为每条聊天记录的唯一标识符',
  `conversation_id` bigint NOT NULL DEFAULT 0 COMMENT '对话编号',
  `reply_id` bigint NOT NULL DEFAULT 0 COMMENT '回复消息编号',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '消息类型',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `role_id` bigint NOT NULL DEFAULT 0 COMMENT '角色编号',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型标志',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `content` text NULL COMMENT '聊天内容',
  `reasoning_content` text NULL COMMENT '推理内容',
  `use_context` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否携带上下文',
  `segment_ids` text NULL COMMENT '知识库段落编号数组',
  `web_search_pages` text NULL COMMENT '联网搜索的网页内容数组',
  `attachment_urls` text NULL COMMENT '附件 URL 数组',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_conversation_id` (`conversation_id`) USING BTREE,
  KEY `idx_reply_id` (`reply_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_role_id` (`role_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI Chat 消息';

-- ----------------------------
-- Table structure for ai_chat_role  [ai]  来源：AiChatRoleDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_chat_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色名称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色头像',
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色分类',
  `description` text NULL COMMENT '角色描述',
  `system_message` text NULL COMMENT '角色设定',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `knowledge_ids` text NULL COMMENT '引用的知识库编号列表',
  `tool_ids` text NULL COMMENT '引用的工具编号列表',
  `mcp_client_names` text NULL COMMENT '引用的 MCP Client 名字列表',
  `public_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否公开',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 聊天角色';

-- ----------------------------
-- Table structure for ai_image  [ai]  来源：AiImageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_image`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `prompt` text NULL COMMENT '提示词',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型标识',
  `width` int NOT NULL DEFAULT 0 COMMENT '图片宽度',
  `height` int NOT NULL DEFAULT 0 COMMENT '图片高度',
  `status` int NOT NULL DEFAULT 0 COMMENT '生成状态',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `error_message` text NULL COMMENT '绘画错误信息',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片地址',
  `public_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否公开',
  `options` text NULL COMMENT '绘制参数，不同 platform 的不同参数',
  `buttons` text NULL COMMENT 'mj buttons 按钮',
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 绘画';

-- ----------------------------
-- Table structure for ai_knowledge  [ai]  来源：AiKnowledgeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_knowledge`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '知识库名称',
  `description` text NULL COMMENT '知识库描述',
  `embedding_model_id` bigint NOT NULL DEFAULT 0 COMMENT '向量模型编号',
  `embedding_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型标识',
  `top_k` int NOT NULL DEFAULT 0 COMMENT 'topK',
  `similarity_threshold` double NOT NULL DEFAULT 0 COMMENT '相似度阈值',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_embedding_model_id` (`embedding_model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 知识库';

-- ----------------------------
-- Table structure for ai_knowledge_document  [ai]  来源：AiKnowledgeDocumentDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_knowledge_document`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `knowledge_id` bigint NOT NULL DEFAULT 0 COMMENT '知识库编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文档名称',
  `url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文件 URL',
  `content` text NULL COMMENT '内容',
  `content_length` int NOT NULL DEFAULT 0 COMMENT '文档长度',
  `tokens` int NOT NULL DEFAULT 0 COMMENT '文档 token 数量',
  `segment_max_tokens` int NOT NULL DEFAULT 0 COMMENT '分片最大 Token 数',
  `retrieval_count` int NOT NULL DEFAULT 0 COMMENT '召回次数',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_knowledge_id` (`knowledge_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 知识库-文档';

-- ----------------------------
-- Table structure for ai_knowledge_segment  [ai]  来源：AiKnowledgeSegmentDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_knowledge_segment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `knowledge_id` bigint NOT NULL DEFAULT 0 COMMENT '知识库编号',
  `document_id` bigint NOT NULL DEFAULT 0 COMMENT '文档编号',
  `content` text NULL COMMENT '切片内容',
  `content_length` int NOT NULL DEFAULT 0 COMMENT '切片内容长度',
  `vector_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '向量库的编号',
  `tokens` int NOT NULL DEFAULT 0 COMMENT 'token 数量',
  `retrieval_count` int NOT NULL DEFAULT 0 COMMENT '召回次数',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_knowledge_id` (`knowledge_id`) USING BTREE,
  KEY `idx_document_id` (`document_id`) USING BTREE,
  KEY `idx_vector_id` (`vector_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 知识库-文档分段';

-- ----------------------------
-- Table structure for ai_mind_map  [ai]  来源：AiMindMapDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_mind_map`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型',
  `prompt` text NULL COMMENT '生成内容提示',
  `generated_content` text NULL COMMENT '生成的内容',
  `error_message` text NULL COMMENT '错误信息',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 思维导图';

-- ----------------------------
-- Table structure for ai_model  [ai]  来源：AiModelDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_model`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `key_id` bigint NOT NULL DEFAULT 0 COMMENT 'API 秘钥编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型名称',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型标志',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `type` int NOT NULL DEFAULT 0 COMMENT '类型',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `temperature` double NOT NULL DEFAULT 0 COMMENT '温度参数',
  `max_tokens` int NOT NULL DEFAULT 0 COMMENT '单条回复的最大 Token 数量',
  `max_contexts` int NOT NULL DEFAULT 0 COMMENT '上下文的最大 Message 数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_key_id` (`key_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 模型';

-- ----------------------------
-- Table structure for ai_music  [ai]  来源：AiMusicDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_music`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '音乐名称',
  `lyric` text NULL COMMENT '歌词',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片地址',
  `audio_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '音频地址',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '音乐状态',
  `generate_mode` int NOT NULL DEFAULT 0 COMMENT '生成模式',
  `description` text NULL COMMENT '描述词',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型',
  `tags` text NULL COMMENT '音乐风格标签',
  `duration` double NOT NULL DEFAULT 0 COMMENT '音乐时长',
  `public_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否公开',
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务编号',
  `error_message` text NULL COMMENT '错误信息',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 音乐';

-- ----------------------------
-- Table structure for ai_tool  [ai]  来源：AiToolDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_tool`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '工具编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具名称',
  `description` text NULL COMMENT '工具描述',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 工具';

-- ----------------------------
-- Table structure for ai_workflow  [ai]  来源：AiWorkflowDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_workflow`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作流名称',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作流标识',
  `graph` text NULL COMMENT '工作流模型 JSON 数据',
  `remark` text NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 工作流';

-- ----------------------------
-- Table structure for ai_write  [ai]  来源：AiWriteDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ai_write`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '写作类型',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台',
  `model_id` bigint NOT NULL DEFAULT 0 COMMENT '模型编号',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型',
  `prompt` text NULL COMMENT '生成内容提示',
  `generated_content` text NULL COMMENT '生成的内容',
  `original_content` text NULL COMMENT '原文',
  `length` int NOT NULL DEFAULT 0 COMMENT '长度提示词',
  `format` int NOT NULL DEFAULT 0 COMMENT '格式提示词',
  `tone` int NOT NULL DEFAULT 0 COMMENT '语气提示词',
  `language` int NOT NULL DEFAULT 0 COMMENT '语言提示词',
  `error_message` text NULL COMMENT '错误信息',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI 写作';

-- ----------------------------
-- Table structure for bpm_category  [bpm]  来源：BpmCategoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类名',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类标志',
  `description` text NULL COMMENT '分类描述',
  `status` int NOT NULL DEFAULT 0 COMMENT '分类状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '分类排序',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 流程分类';

-- ----------------------------
-- Table structure for bpm_form  [bpm]  来源：BpmFormDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_form`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '表单名',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `conf` text NULL COMMENT '表单的配置',
  `fields` text NULL COMMENT '表单项的数组',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 工作流的表单定义';

-- ----------------------------
-- Table structure for bpm_oa_leave  [bpm]  来源：BpmOALeaveDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_oa_leave`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '请假表单主键',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '申请人的用户编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '请假类型',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原因',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `day` bigint NOT NULL DEFAULT 0 COMMENT '请假天数',
  `status` int NOT NULL DEFAULT 0 COMMENT '审批结果',
  `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对应的流程编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_process_instance_id` (`process_instance_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'OA 请假申请';

-- ----------------------------
-- Table structure for bpm_process_definition_info  [bpm]  来源：BpmProcessDefinitionInfoDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_process_definition_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `process_definition_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程定义的编号',
  `model_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程模型的编号',
  `model_type` int NOT NULL DEFAULT 0 COMMENT '流程模型的类型',
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程分类的编码',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标',
  `description` text NULL COMMENT '描述',
  `form_type` int NOT NULL DEFAULT 0 COMMENT '表单类型',
  `form_id` bigint NOT NULL DEFAULT 0 COMMENT '动态表单编号',
  `form_conf` text NULL COMMENT '表单的配置',
  `form_fields` text NULL COMMENT '表单项的数组',
  `form_custom_create_path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自定义表单的提交路径，使用 Vue 的路由地址',
  `form_custom_view_path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自定义表单的查看路径，使用 Vue 的路由地址',
  `simple_model` text NULL COMMENT 'SIMPLE 设计器模型数据 json 格式',
  `visible` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否可见',
  `sort` bigint NOT NULL DEFAULT 0 COMMENT '排序值',
  `start_user_ids` text NULL COMMENT '可发起用户编号数组',
  `start_dept_ids` text NULL COMMENT '可发起部门编号数组',
  `manager_user_ids` text NULL COMMENT '可管理用户编号数组',
  `allow_cancel_running_process` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否允许撤销审批中的申请',
  `allow_withdraw_task` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否允许审批人撤回任务',
  `process_id_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程 ID 规则',
  `auto_approval_type` int NOT NULL DEFAULT 0 COMMENT '自动去重类型',
  `title_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题设置',
  `summary_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '摘要设置',
  `process_before_trigger_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程前置通知设置',
  `process_after_trigger_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程后置通知设置',
  `task_before_trigger_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务前置通知设置',
  `task_after_trigger_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务后置通知设置',
  `print_template_setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自定义打印模板设置',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_definition_id` (`process_definition_id`) USING BTREE,
  KEY `idx_model_id` (`model_id`) USING BTREE,
  KEY `idx_form_id` (`form_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 流程定义的拓信息';

-- ----------------------------
-- Table structure for bpm_process_expression  [bpm]  来源：BpmProcessExpressionDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_process_expression`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '表达式名字',
  `status` int NOT NULL DEFAULT 0 COMMENT '表达式状态',
  `expression` text NULL COMMENT '表达式',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 流程表达式';

-- ----------------------------
-- Table structure for bpm_process_instance_copy  [bpm]  来源：BpmProcessInstanceCopyDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_process_instance_copy`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `start_user_id` bigint NOT NULL DEFAULT 0 COMMENT '发起人 Id',
  `process_instance_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程名',
  `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程实例的编号',
  `process_definition_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程实例的流程定义编号',
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程分类',
  `activity_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程活动的编号',
  `activity_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程活动的名字',
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程活动的编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号（被抄送的用户编号）',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '抄送意见',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_start_user_id` (`start_user_id`) USING BTREE,
  KEY `idx_process_instance_id` (`process_instance_id`) USING BTREE,
  KEY `idx_process_definition_id` (`process_definition_id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流程抄送';

-- ----------------------------
-- Table structure for bpm_process_listener  [bpm]  来源：BpmProcessListenerDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_process_listener`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键 ID，自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '监听器名字',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '监听类型',
  `event` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '监听事件',
  `value_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '值类型',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '值',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 流程监听器';

-- ----------------------------
-- Table structure for bpm_user_group  [bpm]  来源：BpmUserGroupDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `bpm_user_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组名',
  `description` text NULL COMMENT '描述',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `user_ids` text NULL COMMENT '成员用户编号数组',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'BPM 用户组';

-- ----------------------------
-- Table structure for crm_business  [crm]  来源：CrmBusinessDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_business`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商机名称',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `follow_up_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '跟进状态',
  `contact_last_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `contact_next_time` datetime NULL DEFAULT NULL COMMENT '下次联系时间',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人的用户编号',
  `status_type_id` bigint NOT NULL DEFAULT 0 COMMENT '商机状态组编号',
  `status_id` bigint NOT NULL DEFAULT 0 COMMENT '商机状态编号',
  `end_status` int NOT NULL DEFAULT 0 COMMENT '结束状态',
  `end_remark` text NULL COMMENT '结束时的备注',
  `deal_time` datetime NULL DEFAULT NULL COMMENT '预计成交日期',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品总金额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '整单折扣，百分比',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '商机总金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_status_type_id` (`status_type_id`) USING BTREE,
  KEY `idx_status_id` (`status_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 商机';

-- ----------------------------
-- Table structure for crm_business_product  [crm]  来源：CrmBusinessProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_business_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `business_id` bigint NOT NULL DEFAULT 0 COMMENT '商机编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价，单位：元',
  `business_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '商机价格, 单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总计价格，单位：元',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_business_id` (`business_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 商机产品关联表';

-- ----------------------------
-- Table structure for crm_business_status  [crm]  来源：CrmBusinessStatusDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_business_status`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type_id` bigint NOT NULL DEFAULT 0 COMMENT '状态类型编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态名',
  `percent` int NOT NULL DEFAULT 0 COMMENT '赢单率，百分比',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_type_id` (`type_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 商机状态';

-- ----------------------------
-- Table structure for crm_business_status_type  [crm]  来源：CrmBusinessStatusTypeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_business_status_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态类型名',
  `dept_ids` text NULL COMMENT '使用的部门编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 商机状态组';

-- ----------------------------
-- Table structure for crm_clue  [crm]  来源：CrmClueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_clue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '线索名称',
  `follow_up_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '跟进状态',
  `contact_last_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `contact_last_content` text NULL COMMENT '最后跟进内容',
  `contact_next_time` datetime NULL DEFAULT NULL COMMENT '下次联系时间',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人的用户编号',
  `transform_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '转化状态',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电话',
  `qq` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'QQ',
  `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'wechat',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'email',
  `area_id` int NOT NULL DEFAULT 0 COMMENT '所在地',
  `detail_address` text NULL COMMENT '详细地址',
  `industry_id` int NOT NULL DEFAULT 0 COMMENT '所属行业',
  `level` int NOT NULL DEFAULT 0 COMMENT '客户等级',
  `source` int NOT NULL DEFAULT 0 COMMENT '客户来源',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE,
  KEY `idx_industry_id` (`industry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 线索';

-- ----------------------------
-- Table structure for crm_contact  [crm]  来源：CrmContactDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_contact`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人姓名',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `contact_last_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `contact_last_content` text NULL COMMENT '最后跟进内容',
  `contact_next_time` datetime NULL DEFAULT NULL COMMENT '下次联系时间',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人用户编号',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电话',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电子邮箱',
  `qq` bigint NOT NULL DEFAULT 0 COMMENT 'QQ',
  `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '微信',
  `area_id` int NOT NULL DEFAULT 0 COMMENT '所在地',
  `detail_address` text NULL COMMENT '详细地址',
  `sex` int NOT NULL DEFAULT 0 COMMENT '性别',
  `master` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否关键决策人',
  `post` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职位',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '直属上级',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 联系人';

-- ----------------------------
-- Table structure for crm_contact_business  [crm]  来源：CrmContactBusinessDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_contact_business`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `contact_id` bigint NOT NULL DEFAULT 0 COMMENT '联系人编号',
  `business_id` bigint NOT NULL DEFAULT 0 COMMENT '商机编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_contact_id` (`contact_id`) USING BTREE,
  KEY `idx_business_id` (`business_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 联系人与商机的关联';

-- ----------------------------
-- Table structure for crm_contract  [crm]  来源：CrmContractDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_contract`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '合同编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合同名称',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合同编号',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `business_id` bigint NOT NULL DEFAULT 0 COMMENT '商机编号，非必须',
  `contact_last_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人的用户编号',
  `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作流编号',
  `audit_status` int NOT NULL DEFAULT 0 COMMENT '审批状态',
  `order_date` datetime NULL DEFAULT NULL COMMENT '下单日期',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品总金额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '整单折扣',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合同总金额，单位：分',
  `sign_contact_id` bigint NOT NULL DEFAULT 0 COMMENT '客户签约人，非必须',
  `sign_user_id` bigint NOT NULL DEFAULT 0 COMMENT '公司签约人，非必须',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_business_id` (`business_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_process_instance_id` (`process_instance_id`) USING BTREE,
  KEY `idx_sign_contact_id` (`sign_contact_id`) USING BTREE,
  KEY `idx_sign_user_id` (`sign_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 合同';

-- ----------------------------
-- Table structure for crm_contract_config  [crm]  来源：CrmContractConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_contract_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `notify_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否开启提前提醒',
  `notify_days` int NOT NULL DEFAULT 0 COMMENT '提前提醒天数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'crm_contract_config';

-- ----------------------------
-- Table structure for crm_contract_product  [crm]  来源：CrmContractProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_contract_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `contract_id` bigint NOT NULL DEFAULT 0 COMMENT '合同编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价，单位：元',
  `contract_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合同价格, 单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总计价格，单位：元',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_contract_id` (`contract_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 合同产品关联表';

-- ----------------------------
-- Table structure for crm_customer  [crm]  来源：CrmCustomerDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户名称',
  `follow_up_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '跟进状态',
  `contact_last_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `contact_last_content` text NULL COMMENT '最后跟进内容',
  `contact_next_time` datetime NULL DEFAULT NULL COMMENT '下次联系时间',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人的用户编号',
  `owner_time` datetime NULL DEFAULT NULL COMMENT '成为负责人的时间',
  `lock_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '锁定状态',
  `deal_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '成交状态',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电话',
  `qq` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'QQ',
  `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'wechat',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'email',
  `area_id` int NOT NULL DEFAULT 0 COMMENT '所在地',
  `detail_address` text NULL COMMENT '详细地址',
  `industry_id` int NOT NULL DEFAULT 0 COMMENT '所属行业',
  `level` int NOT NULL DEFAULT 0 COMMENT '客户等级',
  `source` int NOT NULL DEFAULT 0 COMMENT '客户来源',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE,
  KEY `idx_industry_id` (`industry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 客户';

-- ----------------------------
-- Table structure for crm_customer_limit_config  [crm]  来源：CrmCustomerLimitConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_customer_limit_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '规则类型',
  `user_ids` text NULL COMMENT '规则适用人群',
  `dept_ids` text NULL COMMENT '规则适用部门',
  `max_count` int NOT NULL DEFAULT 0 COMMENT '数量上限',
  `deal_count_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '成交客户是否占有拥有客户数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '客户限制配置';

-- ----------------------------
-- Table structure for crm_customer_pool_config  [crm]  来源：CrmCustomerPoolConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_customer_pool_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否启用客户公海',
  `contact_expire_days` int NOT NULL DEFAULT 0 COMMENT '未跟进放入公海天数',
  `deal_expire_days` int NOT NULL DEFAULT 0 COMMENT '未成交放入公海天数',
  `notify_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否开启提前提醒',
  `notify_days` int NOT NULL DEFAULT 0 COMMENT '提前提醒天数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '客户公海配置';

-- ----------------------------
-- Table structure for crm_follow_up_record  [crm]  来源：CrmFollowUpRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_follow_up_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '数据类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '数据编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '跟进类型',
  `content` text NULL COMMENT '跟进内容',
  `next_time` datetime NULL DEFAULT NULL COMMENT '下次联系时间',
  `pic_urls` text NULL COMMENT '图片',
  `file_urls` text NULL COMMENT '附件',
  `business_ids` text NULL COMMENT '关联的商机编号数组',
  `contact_ids` text NULL COMMENT '关联的联系人编号数组',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '跟进记录';

-- ----------------------------
-- Table structure for crm_owner_record  [crm]  来源：CrmOwnerRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_owner_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT 'CRM 业务类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT 'CRM 业务编号',
  `pre_owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '变更前负责人',
  `post_owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '变更后负责人',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE,
  KEY `idx_pre_owner_user_id` (`pre_owner_user_id`) USING BTREE,
  KEY `idx_post_owner_user_id` (`post_owner_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 负责人变更记录';

-- ----------------------------
-- Table structure for crm_performance_config  [crm]  来源：CrmPerformanceConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_performance_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '目标类型',
  `object_id` bigint NOT NULL DEFAULT 0 COMMENT '目标对象编号',
  `object_type` int NOT NULL DEFAULT 0 COMMENT '目标对象类型',
  `year` int NOT NULL DEFAULT 0 COMMENT '年份',
  `year_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '年度目标金额',
  `january_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '一月目标金额',
  `february_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '二月目标金额',
  `march_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '三月目标金额',
  `april_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '四月目标金额',
  `may_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '五月目标金额',
  `june_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '六月目标金额',
  `july_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '七月目标金额',
  `august_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '八月目标金额',
  `september_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '九月目标金额',
  `october_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '十月目标金额',
  `november_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '十一月目标金额',
  `december_target_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '十二月目标金额',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_object_id` (`object_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 业绩目标';

-- ----------------------------
-- Table structure for crm_permission  [crm]  来源：CrmPermissionDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '数据类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '数据编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `level` int NOT NULL DEFAULT 0 COMMENT '权限级别',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 数据权限';

-- ----------------------------
-- Table structure for crm_product  [crm]  来源：CrmProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产品名称',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产品编码',
  `unit` int NOT NULL DEFAULT 0 COMMENT '单位',
  `price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '价格，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `category_id` bigint NOT NULL DEFAULT 0 COMMENT '产品分类 ID',
  `description` text NULL COMMENT '产品描述',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人的用户编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_category_id` (`category_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 产品';

-- ----------------------------
-- Table structure for crm_product_category  [crm]  来源：CrmProductCategoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_product_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类名称',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父级编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '产品分类';

-- ----------------------------
-- Table structure for crm_receivable  [crm]  来源：CrmReceivableDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_receivable`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '回款编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '回款计划编号',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `contract_id` bigint NOT NULL DEFAULT 0 COMMENT '合同编号',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人编号，关联 {@link AdminUserRespDTO#getId()}',
  `return_time` datetime NULL DEFAULT NULL COMMENT '回款日期',
  `return_type` int NOT NULL DEFAULT 0 COMMENT '回款方式',
  `price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '计划回款金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作流编号',
  `audit_status` int NOT NULL DEFAULT 0 COMMENT '审批状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_contract_id` (`contract_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_process_instance_id` (`process_instance_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '回款';

-- ----------------------------
-- Table structure for crm_receivable_plan  [crm]  来源：CrmReceivablePlanDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `crm_receivable_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `period` int NOT NULL DEFAULT 0 COMMENT '期数',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `contract_id` bigint NOT NULL DEFAULT 0 COMMENT '合同编号',
  `owner_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人编号',
  `return_time` datetime NULL DEFAULT NULL COMMENT '计划回款日期',
  `return_type` int NOT NULL DEFAULT 0 COMMENT '计划回款类型',
  `price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '计划回款金额，单位：元',
  `receivable_id` bigint NOT NULL DEFAULT 0 COMMENT '回款编号，关联 {@link CrmReceivableDO#getId()}',
  `remind_days` int NOT NULL DEFAULT 0 COMMENT '提前几天提醒',
  `remind_time` datetime NULL DEFAULT NULL COMMENT '提醒日期',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_contract_id` (`contract_id`) USING BTREE,
  KEY `idx_owner_user_id` (`owner_user_id`) USING BTREE,
  KEY `idx_receivable_id` (`receivable_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CRM 回款计划';

-- ----------------------------
-- Table structure for erp_account  [erp]  来源：ErpAccountDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_account`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '结算账户编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账户名称',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账户编码',
  `remark` text NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `default_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否默认',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 结算账户';

-- ----------------------------
-- Table structure for erp_customer  [erp]  来源：ErpCustomerDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '客户编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户名称',
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电子邮箱',
  `fax` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '传真',
  `remark` text NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `tax_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '纳税人识别号',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户行',
  `bank_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户账号',
  `bank_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户地址',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 客户';

-- ----------------------------
-- Table structure for erp_finance_payment  [erp]  来源：ErpFinancePaymentDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_finance_payment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '付款单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '付款状态',
  `payment_time` datetime NULL DEFAULT NULL COMMENT '付款时间',
  `finance_user_id` bigint NOT NULL DEFAULT 0 COMMENT '财务人员编号',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '付款账户编号',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计价格，单位：元',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `payment_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '实付金额，单位：分',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_finance_user_id` (`finance_user_id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 付款单';

-- ----------------------------
-- Table structure for erp_finance_payment_item  [erp]  来源：ErpFinancePaymentItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_finance_payment_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
  `payment_id` bigint NOT NULL DEFAULT 0 COMMENT '付款单编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '业务编号',
  `biz_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务单号',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '应付金额，单位：分',
  `paid_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已付金额，单位：分',
  `payment_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次付款，单位：分',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_payment_id` (`payment_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 付款项';

-- ----------------------------
-- Table structure for erp_finance_receipt  [erp]  来源：ErpFinanceReceiptDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_finance_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '收款状态',
  `receipt_time` datetime NULL DEFAULT NULL COMMENT '收款时间',
  `finance_user_id` bigint NOT NULL DEFAULT 0 COMMENT '财务人员编号',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '收款账户编号',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计价格，单位：元',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `receipt_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '实付金额，单位：分',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_finance_user_id` (`finance_user_id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 收款单';

-- ----------------------------
-- Table structure for erp_finance_receipt_item  [erp]  来源：ErpFinanceReceiptItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_finance_receipt_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '收款单编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '业务编号',
  `biz_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务单号',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '应收金额，单位：分',
  `receipted_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已收金额，单位：分',
  `receipt_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次收款，单位：分',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 收款项';

-- ----------------------------
-- Table structure for erp_product  [erp]  来源：ErpProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '产品编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产品名称',
  `bar_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产品条码',
  `category_id` bigint NOT NULL DEFAULT 0 COMMENT '产品分类编号',
  `unit_id` bigint NOT NULL DEFAULT 0 COMMENT '单位编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '产品状态',
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产品规格',
  `remark` text NULL COMMENT '产品备注',
  `expiry_day` int NOT NULL DEFAULT 0 COMMENT '保质期天数',
  `weight` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '基础重量（kg）',
  `purchase_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '采购价格，单位：元',
  `sale_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '销售价格，单位：元',
  `min_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最低价格，单位：元',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_category_id` (`category_id`) USING BTREE,
  KEY `idx_unit_id` (`unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 产品';

-- ----------------------------
-- Table structure for erp_product_category  [erp]  来源：ErpProductCategoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_product_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类编号',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父分类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类名称',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类编码',
  `sort` int NOT NULL DEFAULT 0 COMMENT '分类排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 产品分类';

-- ----------------------------
-- Table structure for erp_product_unit  [erp]  来源：ErpProductUnitDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_product_unit`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '单位编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位名字',
  `status` int NOT NULL DEFAULT 0 COMMENT '单位状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 产品单位';

-- ----------------------------
-- Table structure for erp_purchase_in  [erp]  来源：ErpPurchaseInDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购入库单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '入库状态',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '采购订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单号',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `payment_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已支付金额，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `other_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其它金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购入库';

-- ----------------------------
-- Table structure for erp_purchase_in_items  [erp]  来源：ErpPurchaseInItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_in_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `in_id` bigint NOT NULL DEFAULT 0 COMMENT '采购入库编号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '采购订单项编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_in_id` (`in_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购入库项';

-- ----------------------------
-- Table structure for erp_purchase_order  [erp]  来源：ErpPurchaseOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '采购状态',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `order_time` datetime NULL DEFAULT NULL COMMENT '下单时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `deposit_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '定金金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `in_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '采购入库数量',
  `return_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '采购退货数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购订单';

-- ----------------------------
-- Table structure for erp_purchase_order_items  [erp]  来源：ErpPurchaseOrderItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_order_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '采购订单编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `in_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '采购入库数量',
  `return_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '采购退货数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购订单项';

-- ----------------------------
-- Table structure for erp_purchase_return  [erp]  来源：ErpPurchaseReturnDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_return`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购退货单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '退货状态',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `return_time` datetime NULL DEFAULT NULL COMMENT '退货时间',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '采购订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单号',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `refund_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已退款金额，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `other_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其它金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购退货';

-- ----------------------------
-- Table structure for erp_purchase_return_items  [erp]  来源：ErpPurchaseReturnItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_purchase_return_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '采购退货编号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '采购订单项编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 采购退货项';

-- ----------------------------
-- Table structure for erp_sale_order  [erp]  来源：ErpSaleOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '销售状态',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `sale_user_id` bigint NOT NULL DEFAULT 0 COMMENT '销售员编号',
  `order_time` datetime NULL DEFAULT NULL COMMENT '下单时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `deposit_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '定金金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `out_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '销售出库数量',
  `return_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '销售退货数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE,
  KEY `idx_sale_user_id` (`sale_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售订单';

-- ----------------------------
-- Table structure for erp_sale_order_items  [erp]  来源：ErpSaleOrderItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_order_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '销售订单编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `out_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '销售出库数量',
  `return_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '销售退货数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售订单项';

-- ----------------------------
-- Table structure for erp_sale_out  [erp]  来源：ErpSaleOutDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售出库单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '出库状态',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `sale_user_id` bigint NOT NULL DEFAULT 0 COMMENT '销售员编号',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '销售订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单号',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `receipt_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已收款金额，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `other_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其它金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE,
  KEY `idx_sale_user_id` (`sale_user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售出库';

-- ----------------------------
-- Table structure for erp_sale_out_items  [erp]  来源：ErpSaleOutItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_out_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `out_id` bigint NOT NULL DEFAULT 0 COMMENT '销售出库编号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '销售订单项编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_out_id` (`out_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售出库项';

-- ----------------------------
-- Table structure for erp_sale_return  [erp]  来源：ErpSaleReturnDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_return`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售退货单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '退货状态',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `account_id` bigint NOT NULL DEFAULT 0 COMMENT '结算账户编号',
  `sale_user_id` bigint NOT NULL DEFAULT 0 COMMENT '销售员编号',
  `return_time` datetime NULL DEFAULT NULL COMMENT '退货时间',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '销售订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单号',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最终合计价格，单位：元',
  `refund_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已退款金额，单位：元',
  `total_product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计产品价格，单位：元',
  `total_tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计税额，单位：元',
  `discount_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠率，百分比',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：元',
  `other_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其它金额，单位：元',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_account_id` (`account_id`) USING BTREE,
  KEY `idx_sale_user_id` (`sale_user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售退货';

-- ----------------------------
-- Table structure for erp_sale_return_items  [erp]  来源：ErpSaleReturnItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_sale_return_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '销售退货编号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '销售订单项编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位单位',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单位单价，单位：元',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总价，单位：元',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率，百分比',
  `tax_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 销售退货项';

-- ----------------------------
-- Table structure for erp_stock  [erp]  来源：ErpStockDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '库存数量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 产品库存';

-- ----------------------------
-- Table structure for erp_stock_check  [erp]  来源：ErpStockCheckDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_check`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '盘点编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '盘点单号',
  `check_time` datetime NULL DEFAULT NULL COMMENT '盘点时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件 URL',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 库存盘点单';

-- ----------------------------
-- Table structure for erp_stock_check_item  [erp]  来源：ErpStockCheckItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_check_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '盘点项编号',
  `check_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价',
  `stock_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '账面数量（当前库存）',
  `actual_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '实际数量（实际库存）',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '盈亏数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_check_id` (`check_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 库存盘点单项';

-- ----------------------------
-- Table structure for erp_stock_in  [erp]  来源：ErpStockInDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单号',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件 URL',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 其它入库单';

-- ----------------------------
-- Table structure for erp_stock_in_item  [erp]  来源：ErpStockInItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_in_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
  `in_id` bigint NOT NULL DEFAULT 0 COMMENT '入库编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_in_id` (`in_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 其它入库单项';

-- ----------------------------
-- Table structure for erp_stock_move  [erp]  来源：ErpStockMoveDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_move`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '调拨编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '调拨单号',
  `move_time` datetime NULL DEFAULT NULL COMMENT '调拨时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件 URL',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 库存调拨单';

-- ----------------------------
-- Table structure for erp_stock_move_item  [erp]  来源：ErpStockMoveItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_move_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '调拨项编号',
  `move_id` bigint NOT NULL DEFAULT 0 COMMENT '调拨编号',
  `from_warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '调出仓库编号',
  `to_warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '调入仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_move_id` (`move_id`) USING BTREE,
  KEY `idx_from_warehouse_id` (`from_warehouse_id`) USING BTREE,
  KEY `idx_to_warehouse_id` (`to_warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 库存调拨单项';

-- ----------------------------
-- Table structure for erp_stock_out  [erp]  来源：ErpStockOutDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '出库编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库单号',
  `customer_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件 URL',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 其它出库单';

-- ----------------------------
-- Table structure for erp_stock_out_item  [erp]  来源：ErpStockOutItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_out_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '出库项编号',
  `out_id` bigint NOT NULL DEFAULT 0 COMMENT '出库编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `product_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '产品单位编号',
  `product_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品单价',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产品数量',
  `total_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合计金额，单位：元',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_out_id` (`out_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_product_unit_id` (`product_unit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 其它出库单项';

-- ----------------------------
-- Table structure for erp_stock_record  [erp]  来源：ErpStockRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_stock_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '出入库数量',
  `total_count` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总库存量',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '业务编号',
  `biz_item_id` bigint NOT NULL DEFAULT 0 COMMENT '业务项编号',
  `biz_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务单号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE,
  KEY `idx_biz_item_id` (`biz_item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 产品库存明细';

-- ----------------------------
-- Table structure for erp_supplier  [erp]  来源：ErpSupplierDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_supplier`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '供应商编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商名称',
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电子邮箱',
  `fax` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '传真',
  `remark` text NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `tax_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '纳税人识别号',
  `tax_percent` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '税率',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户行',
  `bank_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户账号',
  `bank_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户地址',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 供应商';

-- ----------------------------
-- Table structure for erp_warehouse  [erp]  来源：ErpWarehouseDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `erp_warehouse`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '仓库编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `sort` bigint NOT NULL DEFAULT 0 COMMENT '排序',
  `remark` text NULL COMMENT '备注',
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '负责人',
  `warehouse_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '仓储费，单位：元',
  `truckage_price` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '搬运费，单位：元',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `default_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否默认',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ERP 仓库';

-- ----------------------------
-- Table structure for member_address  [member]  来源：MemberAddressDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收件人名称',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '地区编号',
  `detail_address` text NULL COMMENT '收件详细地址',
  `default_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否默认',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收件地址';

-- ----------------------------
-- Table structure for member_config  [member]  来源：MemberConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `point_trade_deduct_enable` bit(1) NOT NULL DEFAULT b'0' COMMENT '积分抵扣开关',
  `point_trade_deduct_unit_price` int NOT NULL DEFAULT 0 COMMENT '积分抵扣，单位：分',
  `point_trade_deduct_max_price` int NOT NULL DEFAULT 0 COMMENT '积分抵扣最大值',
  `point_trade_give_point` int NOT NULL DEFAULT 0 COMMENT '1 元赠送多少分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员配置';

-- ----------------------------
-- Table structure for member_experience_record  [member]  来源：MemberExperienceRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_experience_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `description` text NULL COMMENT '描述',
  `experience` int NOT NULL DEFAULT 0 COMMENT '经验',
  `total_experience` int NOT NULL DEFAULT 0 COMMENT '变更后的经验',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员经验记录';

-- ----------------------------
-- Table structure for member_group  [member]  来源：MemberGroupDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `remark` text NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户分组';

-- ----------------------------
-- Table structure for member_level  [member]  来源：MemberLevelDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_level`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '等级名称',
  `level` int NOT NULL DEFAULT 0 COMMENT '等级',
  `experience` int NOT NULL DEFAULT 0 COMMENT '升级经验',
  `discount_percent` int NOT NULL DEFAULT 0 COMMENT '享受折扣',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '等级图标',
  `background_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '等级背景图',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员等级';

-- ----------------------------
-- Table structure for member_level_record  [member]  来源：MemberLevelRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_level_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `level_id` bigint NOT NULL DEFAULT 0 COMMENT '等级编号',
  `level` int NOT NULL DEFAULT 0 COMMENT '会员等级',
  `discount_percent` int NOT NULL DEFAULT 0 COMMENT '享受折扣',
  `experience` int NOT NULL DEFAULT 0 COMMENT '升级经验',
  `user_experience` int NOT NULL DEFAULT 0 COMMENT '会员此时的经验',
  `remark` text NULL COMMENT '备注',
  `description` text NULL COMMENT '描述',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_level_id` (`level_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员等级记录';

-- ----------------------------
-- Table structure for member_point_record  [member]  来源：MemberPointRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_point_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务编码',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '积分标题',
  `description` text NULL COMMENT '积分描述',
  `point` int NOT NULL DEFAULT 0 COMMENT '变动积分',
  `total_point` int NOT NULL DEFAULT 0 COMMENT '变动后的积分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户积分记录';

-- ----------------------------
-- Table structure for member_sign_in_config  [member]  来源：MemberSignInConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_sign_in_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则自增主键',
  `day` int NOT NULL DEFAULT 0 COMMENT '签到第 x 天',
  `point` int NOT NULL DEFAULT 0 COMMENT '奖励积分',
  `experience` int NOT NULL DEFAULT 0 COMMENT '奖励经验',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '签到规则';

-- ----------------------------
-- Table structure for member_sign_in_record  [member]  来源：MemberSignInRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_sign_in_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '签到用户',
  `day` int NOT NULL DEFAULT 0 COMMENT '第几天签到',
  `point` int NOT NULL DEFAULT 0 COMMENT '签到的积分',
  `experience` int NOT NULL DEFAULT 0 COMMENT '签到的经验',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '签到记录';

-- ----------------------------
-- Table structure for member_tag  [member]  来源：MemberTagDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_tag`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签名称',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员标签';

-- ----------------------------
-- Table structure for member_user  [member]  来源：MemberUserDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `member_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '加密后的密码',
  `status` int NOT NULL DEFAULT 0 COMMENT '帐号状态',
  `register_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '注册 IP',
  `register_terminal` int NOT NULL DEFAULT 0 COMMENT '注册终端',
  `login_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户头像',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实名字',
  `sex` int NOT NULL DEFAULT 0 COMMENT '性别',
  `birthday` datetime NULL DEFAULT NULL COMMENT '出生日期',
  `area_id` int NOT NULL DEFAULT 0 COMMENT '所在地',
  `mark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户备注',
  `point` int NOT NULL DEFAULT 0 COMMENT '积分',
  `tag_ids` text NULL COMMENT '会员标签列表，以逗号分隔',
  `level_id` bigint NOT NULL DEFAULT 0 COMMENT '会员级别编号',
  `experience` int NOT NULL DEFAULT 0 COMMENT '会员经验',
  `group_id` bigint NOT NULL DEFAULT 0 COMMENT '用户分组编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE,
  KEY `idx_level_id` (`level_id`) USING BTREE,
  KEY `idx_group_id` (`group_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员用户';

-- ----------------------------
-- Table structure for mes_cal_holiday  [mes]  来源：MesCalHolidayDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_holiday`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `day` datetime NULL DEFAULT NULL COMMENT '日期',
  `type` int NOT NULL DEFAULT 0 COMMENT '日期类型',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 假期设置';

-- ----------------------------
-- Table structure for mes_cal_plan  [mes]  来源：MesCalPlanDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '计划编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '计划编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '计划名称',
  `calendar_type` int NOT NULL DEFAULT 0 COMMENT '班组类型',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `shift_type` int NOT NULL DEFAULT 0 COMMENT '轮班方式',
  `shift_method` int NOT NULL DEFAULT 0 COMMENT '倒班方式',
  `shift_count` int NOT NULL DEFAULT 0 COMMENT '倒班天数',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 排班计划';

-- ----------------------------
-- Table structure for mes_cal_plan_shift  [mes]  来源：MesCalPlanShiftDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_plan_shift`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '班次编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '排班计划编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次名称',
  `start_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开始时间（HH:mm 格式）',
  `end_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结束时间（HH:mm 格式）',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 计划班次';

-- ----------------------------
-- Table structure for mes_cal_plan_team  [mes]  来源：MesCalPlanTeamDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_plan_team`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '排班计划编号',
  `team_id` bigint NOT NULL DEFAULT 0 COMMENT '班组编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_team_id` (`team_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 计划班组关联';

-- ----------------------------
-- Table structure for mes_cal_team  [mes]  来源：MesCalTeamDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_team`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '班组编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班组编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班组名称',
  `calendar_type` int NOT NULL DEFAULT 0 COMMENT '班组类型',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 班组';

-- ----------------------------
-- Table structure for mes_cal_team_member  [mes]  来源：MesCalTeamMemberDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_team_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '班组成员编号',
  `team_id` bigint NOT NULL DEFAULT 0 COMMENT '班组编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_team_id` (`team_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 班组成员';

-- ----------------------------
-- Table structure for mes_cal_team_shift  [mes]  来源：MesCalTeamShiftDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_cal_team_shift`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '排班计划编号',
  `team_id` bigint NOT NULL DEFAULT 0 COMMENT '班组编号',
  `shift_id` bigint NOT NULL DEFAULT 0 COMMENT '班次编号',
  `day` datetime NULL DEFAULT NULL COMMENT '日期',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_team_id` (`team_id`) USING BTREE,
  KEY `idx_shift_id` (`shift_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 班组排班';

-- ----------------------------
-- Table structure for mes_dv_check_plan  [mes]  来源：MesDvCheckPlanDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_check_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '方案类型',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `cycle_type` int NOT NULL DEFAULT 0 COMMENT '周期类型',
  `cycle_count` int NOT NULL DEFAULT 0 COMMENT '周期数量',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 点检保养方案';

-- ----------------------------
-- Table structure for mes_dv_check_plan_machinery  [mes]  来源：MesDvCheckPlanMachineryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_check_plan_machinery`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '方案编号',
  `machinery_id` bigint NOT NULL DEFAULT 0 COMMENT '设备编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_machinery_id` (`machinery_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 点检保养方案设备';

-- ----------------------------
-- Table structure for mes_dv_check_plan_subject  [mes]  来源：MesDvCheckPlanSubjectDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_check_plan_subject`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '方案编号',
  `subject_id` bigint NOT NULL DEFAULT 0 COMMENT '项目编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_subject_id` (`subject_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 点检保养方案项目';

-- ----------------------------
-- Table structure for mes_dv_check_record  [mes]  来源：MesDvCheckRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_check_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '点检计划编号',
  `machinery_id` bigint NOT NULL DEFAULT 0 COMMENT '设备编号',
  `check_time` datetime NULL DEFAULT NULL COMMENT '点检时间',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '点检人编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_machinery_id` (`machinery_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备点检记录';

-- ----------------------------
-- Table structure for mes_dv_check_record_line  [mes]  来源：MesDvCheckRecordLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_check_record_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `record_id` bigint NOT NULL DEFAULT 0 COMMENT '点检记录编号',
  `subject_id` bigint NOT NULL DEFAULT 0 COMMENT '点检项目编号',
  `check_status` int NOT NULL DEFAULT 0 COMMENT '点检结果',
  `check_result` text NULL COMMENT '异常描述',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_record_id` (`record_id`) USING BTREE,
  KEY `idx_subject_id` (`subject_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备点检记录明细';

-- ----------------------------
-- Table structure for mes_dv_machinery  [mes]  来源：MesDvMachineryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_machinery`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备名称',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌',
  `specification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格型号',
  `machinery_type_id` bigint NOT NULL DEFAULT 0 COMMENT '设备类型编号',
  `workshop_id` bigint NOT NULL DEFAULT 0 COMMENT '所属车间编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '设备状态',
  `last_mainten_time` datetime NULL DEFAULT NULL COMMENT '最近保养时间',
  `last_check_time` datetime NULL DEFAULT NULL COMMENT '最近点检时间',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_machinery_type_id` (`machinery_type_id`) USING BTREE,
  KEY `idx_workshop_id` (`workshop_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备台账';

-- ----------------------------
-- Table structure for mes_dv_machinery_type  [mes]  来源：MesDvMachineryTypeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_machinery_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型名称',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父类型编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '显示排序',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备类型';

-- ----------------------------
-- Table structure for mes_dv_mainten_record  [mes]  来源：MesDvMaintenRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_mainten_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '计划编号',
  `machinery_id` bigint NOT NULL DEFAULT 0 COMMENT '设备编号',
  `mainten_time` datetime NULL DEFAULT NULL COMMENT '保养时间',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_machinery_id` (`machinery_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备保养记录';

-- ----------------------------
-- Table structure for mes_dv_mainten_record_line  [mes]  来源：MesDvMaintenRecordLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_mainten_record_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `record_id` bigint NOT NULL DEFAULT 0 COMMENT '保养记录编号',
  `subject_id` bigint NOT NULL DEFAULT 0 COMMENT '项目编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '保养结果',
  `result` text NULL COMMENT '异常描述',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_record_id` (`record_id`) USING BTREE,
  KEY `idx_subject_id` (`subject_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备保养记录明细';

-- ----------------------------
-- Table structure for mes_dv_repair  [mes]  来源：MesDvRepairDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_repair`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '维修工单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '维修工单名称',
  `machinery_id` bigint NOT NULL DEFAULT 0 COMMENT '设备编号',
  `require_date` datetime NULL DEFAULT NULL COMMENT '报修日期',
  `finish_date` datetime NULL DEFAULT NULL COMMENT '维修完成日期',
  `confirm_date` datetime NULL DEFAULT NULL COMMENT '验收日期',
  `result` int NOT NULL DEFAULT 0 COMMENT '维修结果',
  `accepted_user_id` bigint NOT NULL DEFAULT 0 COMMENT '维修人用户编号',
  `confirm_user_id` bigint NOT NULL DEFAULT 0 COMMENT '验收人用户编号',
  `source_doc_type` int NOT NULL DEFAULT 0 COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据编号',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编码',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_machinery_id` (`machinery_id`) USING BTREE,
  KEY `idx_accepted_user_id` (`accepted_user_id`) USING BTREE,
  KEY `idx_confirm_user_id` (`confirm_user_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 维修工单';

-- ----------------------------
-- Table structure for mes_dv_repair_line  [mes]  来源：MesDvRepairLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_repair_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `repair_id` bigint NOT NULL DEFAULT 0 COMMENT '维修工单编号',
  `subject_id` bigint NOT NULL DEFAULT 0 COMMENT '点检保养项目编号',
  `malfunction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '故障描述',
  `malfunction_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '故障图片 URL',
  `description` text NULL COMMENT '维修描述',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_repair_id` (`repair_id`) USING BTREE,
  KEY `idx_subject_id` (`subject_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 维修工单行';

-- ----------------------------
-- Table structure for mes_dv_subject  [mes]  来源：MesDvSubjectDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_dv_subject`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '项目类型',
  `content` text NULL COMMENT '项目内容',
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标准',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 点检保养项目';

-- ----------------------------
-- Table structure for mes_md_auto_code_part  [mes]  来源：MesMdAutoCodePartDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_auto_code_part`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分段 ID',
  `rule_id` bigint NOT NULL DEFAULT 0 COMMENT '规则 ID',
  `sort` int NOT NULL DEFAULT 0 COMMENT '分段序号',
  `type` int NOT NULL DEFAULT 0 COMMENT '分段类型',
  `length` int NOT NULL DEFAULT 0 COMMENT '分段长度',
  `date_format` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '日期格式',
  `fix_character` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '固定字符',
  `serial_start_no` int NOT NULL DEFAULT 0 COMMENT '流水号起始值',
  `serial_step` int NOT NULL DEFAULT 0 COMMENT '流水号步长',
  `cycle_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '流水号是否循环',
  `cycle_method` int NOT NULL DEFAULT 0 COMMENT '循环方式',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_rule_id` (`rule_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 编码规则组成';

-- ----------------------------
-- Table structure for mes_md_auto_code_record  [mes]  来源：MesMdAutoCodeRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_auto_code_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `rule_id` bigint NOT NULL DEFAULT 0 COMMENT '规则 ID',
  `result` text NULL COMMENT '生成的编码',
  `serial_no` bigint NOT NULL DEFAULT 0 COMMENT '生成的流水号',
  `input_char` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '传入的参数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_rule_id` (`rule_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 编码生成记录';

-- ----------------------------
-- Table structure for mes_md_auto_code_rule  [mes]  来源：MesMdAutoCodeRuleDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_auto_code_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则 ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规则编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规则名称',
  `description` text NULL COMMENT '描述',
  `max_length` int NOT NULL DEFAULT 0 COMMENT '最大长度',
  `padded` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否补齐',
  `padded_char` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '补齐字符',
  `padded_method` int NOT NULL DEFAULT 0 COMMENT '补齐方式',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 编码规则';

-- ----------------------------
-- Table structure for mes_md_client  [mes]  来源：MesMdClientDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_client`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '客户编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户名称',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户简称',
  `english_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户英文名称',
  `description` text NULL COMMENT '客户简介',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户LOGO地址',
  `type` int NOT NULL DEFAULT 0 COMMENT '客户类型',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户地址',
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户官网地址',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户邮箱地址',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户电话',
  `contact1_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1',
  `contact1_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1-电话',
  `contact1_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1-邮箱',
  `contact2_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2',
  `contact2_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2-电话',
  `contact2_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2-邮箱',
  `credit_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '统一社会信用代码',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 客户';

-- ----------------------------
-- Table structure for mes_md_item  [mes]  来源：MesMdItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物料编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物料编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物料名称',
  `specification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格型号',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位编号',
  `item_type_id` bigint NOT NULL DEFAULT 0 COMMENT '物料分类编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `safe_stock_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否启用安全库存',
  `min_stock` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最低库存量',
  `max_stock` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最高库存量',
  `high_value` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否高值物料',
  `batch_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否启用批次管理',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE,
  KEY `idx_item_type_id` (`item_type_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料产品';

-- ----------------------------
-- Table structure for mes_md_item_batch_config  [mes]  来源：MesMdItemBatchConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_item_batch_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `produce_date_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-生产日期',
  `expire_date_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-有效期',
  `receipt_date_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-入库日期',
  `vendor_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-供应商',
  `client_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-客户',
  `sales_order_code_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-销售订单编号',
  `purchase_order_code_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-采购订单编号',
  `work_order_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-生产工单',
  `task_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-生产任务',
  `workstation_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-工作站',
  `tool_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-工具',
  `mold_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-模具',
  `lot_number_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-生产批号',
  `quality_status_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '批次属性-质量状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料批次属性配置';

-- ----------------------------
-- Table structure for mes_md_item_type  [mes]  来源：MesMdItemTypeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_item_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类名称',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父分类编号',
  `item_or_product` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物料/产品标识',
  `sort` int NOT NULL DEFAULT 0 COMMENT '显示排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料产品分类';

-- ----------------------------
-- Table structure for mes_md_product_bom  [mes]  来源：MesMdProductBomDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_product_bom`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'BOM编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料产品编号',
  `bom_item_id` bigint NOT NULL DEFAULT 0 COMMENT 'BOM物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '物料使用比例',
  `status` int NOT NULL DEFAULT 0 COMMENT '是否启用',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_bom_item_id` (`bom_item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品 BOM';

-- ----------------------------
-- Table structure for mes_md_product_sip  [mes]  来源：MesMdProductSipDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_product_sip`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料产品编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排列顺序',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `description` text NULL COMMENT '详细描述',
  `url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品SIP';

-- ----------------------------
-- Table structure for mes_md_product_sop  [mes]  来源：MesMdProductSopDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_product_sop`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料产品编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排列顺序',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `description` text NULL COMMENT '详细描述',
  `url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片地址',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品SOP';

-- ----------------------------
-- Table structure for mes_md_unit_measure  [mes]  来源：MesMdUnitMeasureDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_unit_measure`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '单位编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位名称',
  `primary_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否主单位',
  `primary_id` bigint NOT NULL DEFAULT 0 COMMENT '主单位编号',
  `change_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '与主单位换算比例',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_primary_id` (`primary_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 计量单位';

-- ----------------------------
-- Table structure for mes_md_vendor  [mes]  来源：MesMdVendorDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_vendor`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '供应商编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商名称',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商简称',
  `english_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商英文名称',
  `description` text NULL COMMENT '供应商简介',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商LOGO地址',
  `level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商等级',
  `score` int NOT NULL DEFAULT 0 COMMENT '供应商评分',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商地址',
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商官网地址',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商邮箱地址',
  `telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商电话',
  `contact1_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1',
  `contact1_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1-电话',
  `contact1_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人1-邮箱',
  `contact2_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2',
  `contact2_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2-电话',
  `contact2_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人2-邮箱',
  `credit_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '统一社会信用代码',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 供应商';

-- ----------------------------
-- Table structure for mes_md_workshop  [mes]  来源：MesMdWorkshopDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_workshop`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '车间编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '车间名称',
  `area` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '面积（平方米）',
  `charge_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人用户编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_charge_user_id` (`charge_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 车间';

-- ----------------------------
-- Table structure for mes_md_workstation  [mes]  来源：MesMdWorkstationDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_workstation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作站编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作站名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作站地点',
  `workshop_id` bigint NOT NULL DEFAULT 0 COMMENT '所在车间编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '线边库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workshop_id` (`workshop_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工作站';

-- ----------------------------
-- Table structure for mes_md_workstation_machine  [mes]  来源：MesMdWorkstationMachineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_workstation_machine`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `machinery_id` bigint NOT NULL DEFAULT 0 COMMENT '设备编号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_machinery_id` (`machinery_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 设备资源';

-- ----------------------------
-- Table structure for mes_md_workstation_tool  [mes]  来源：MesMdWorkstationToolDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_workstation_tool`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `tool_type_id` bigint NOT NULL DEFAULT 0 COMMENT '工具类型编号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_tool_type_id` (`tool_type_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工装夹具资源';

-- ----------------------------
-- Table structure for mes_md_workstation_worker  [mes]  来源：MesMdWorkstationWorkerDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_md_workstation_worker`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `post_id` bigint NOT NULL DEFAULT 0 COMMENT '岗位编号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_post_id` (`post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 人力资源';

-- ----------------------------
-- Table structure for mes_pro_andon_config  [mes]  来源：MesProAndonConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_andon_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '呼叫原因',
  `level` int NOT NULL DEFAULT 0 COMMENT '级别',
  `handler_role_id` bigint NOT NULL DEFAULT 0 COMMENT '处置人角色编号',
  `handler_user_id` bigint NOT NULL DEFAULT 0 COMMENT '处置人编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_handler_role_id` (`handler_role_id`) USING BTREE,
  KEY `idx_handler_user_id` (`handler_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 安灯呼叫配置';

-- ----------------------------
-- Table structure for mes_pro_andon_record  [mes]  来源：MesProAndonRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_andon_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `config_id` bigint NOT NULL DEFAULT 0 COMMENT '安灯配置编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '发起用户编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '呼叫原因（快照值，不随配置变更）',
  `level` int NOT NULL DEFAULT 0 COMMENT '级别（快照值）',
  `status` int NOT NULL DEFAULT 0 COMMENT '处置状态',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处置时间',
  `handler_user_id` bigint NOT NULL DEFAULT 0 COMMENT '处置人编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_config_id` (`config_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_handler_user_id` (`handler_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 安灯呼叫记录';

-- ----------------------------
-- Table structure for mes_pro_card  [mes]  来源：MesProCardDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_card`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流转卡编码',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `transfered_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '流转数量',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产流转卡';

-- ----------------------------
-- Table structure for mes_pro_card_process  [mes]  来源：MesProCardProcessDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_card_process`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `card_id` bigint NOT NULL DEFAULT 0 COMMENT '流转卡编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '序号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `input_time` datetime NULL DEFAULT NULL COMMENT '进入工序时间',
  `output_time` datetime NULL DEFAULT NULL COMMENT '出工序时间',
  `input_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '投入数量',
  `output_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '产出数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不合格品数量',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工位编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '操作人编号',
  `ipqc_id` bigint NOT NULL DEFAULT 0 COMMENT '过程检验单编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_card_id` (`card_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_ipqc_id` (`ipqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 流转卡工序记录';

-- ----------------------------
-- Table structure for mes_pro_feedback  [mes]  来源：MesProFeedbackDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报工单编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '报工类型',
  `channel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报工途径',
  `feedback_time` datetime NULL DEFAULT NULL COMMENT '报工时间',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `route_id` bigint NOT NULL DEFAULT 0 COMMENT '工艺路线编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号（冗余自任务）',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '过期日期',
  `lot_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产批号',
  `scheduled_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '排产数量',
  `feedback_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次报工数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不良品数量',
  `uncheck_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '待检测数量',
  `labor_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '工废数量',
  `material_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '料废数量',
  `other_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其他废品数量',
  `feedback_user_id` bigint NOT NULL DEFAULT 0 COMMENT '报工用户编号',
  `approve_user_id` bigint NOT NULL DEFAULT 0 COMMENT '审核用户编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_route_id` (`route_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_feedback_user_id` (`feedback_user_id`) USING BTREE,
  KEY `idx_approve_user_id` (`approve_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产报工';

-- ----------------------------
-- Table structure for mes_pro_process  [mes]  来源：MesProProcessDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_process`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工序编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工序名称',
  `attention` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工艺要求',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产工序';

-- ----------------------------
-- Table structure for mes_pro_process_content  [mes]  来源：MesProProcessContentDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_process_content`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '顺序编号',
  `content` text NULL COMMENT '步骤说明',
  `device` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '辅助设备',
  `material` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '辅助材料',
  `doc_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '材料文档 URL',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产工序内容';

-- ----------------------------
-- Table structure for mes_pro_route  [mes]  来源：MesProRouteDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_route`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工艺路线编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工艺路线名称',
  `description` text NULL COMMENT '工艺路线说明',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工艺路线';

-- ----------------------------
-- Table structure for mes_pro_route_process  [mes]  来源：MesProRouteProcessDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_route_process`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `route_id` bigint NOT NULL DEFAULT 0 COMMENT '工艺路线编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `sort` int NOT NULL DEFAULT 0 COMMENT '序号',
  `next_process_id` bigint NOT NULL DEFAULT 0 COMMENT '下一道工序编号',
  `link_type` int NOT NULL DEFAULT 0 COMMENT '与下一道工序关系',
  `prepare_time` int NOT NULL DEFAULT 0 COMMENT '准备时间（分钟）',
  `wait_time` int NOT NULL DEFAULT 0 COMMENT '等待时间（分钟）',
  `color_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '甘特图显示颜色',
  `key_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否关键工序',
  `check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否质检工序',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_route_id` (`route_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_next_process_id` (`next_process_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工艺路线工序';

-- ----------------------------
-- Table structure for mes_pro_route_product  [mes]  来源：MesProRouteProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_route_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `route_id` bigint NOT NULL DEFAULT 0 COMMENT '工艺路线编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '生产数量',
  `production_time` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '生产用时',
  `time_unit_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '时间单位',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_route_id` (`route_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工艺路线产品';

-- ----------------------------
-- Table structure for mes_pro_route_product_bom  [mes]  来源：MesProRouteProductBomDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_route_product_bom`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `route_id` bigint NOT NULL DEFAULT 0 COMMENT '工艺路线编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT 'BOM 物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '用料比例',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_route_id` (`route_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工艺路线产品 BOM';

-- ----------------------------
-- Table structure for mes_pro_task  [mes]  来源：MesProTaskDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务名称',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `route_id` bigint NOT NULL DEFAULT 0 COMMENT '工艺路线编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '排产数量',
  `produced_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已生产数量',
  `qualify_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualify_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不良品数量',
  `changed_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '调整数量',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始生产时间',
  `duration` int NOT NULL DEFAULT 0 COMMENT '生产时长（工作日，1=8小时）',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束生产时间',
  `color_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '甘特图显示颜色',
  `finish_date` datetime NULL DEFAULT NULL COMMENT '完成日期',
  `cancel_date` datetime NULL DEFAULT NULL COMMENT '取消日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '任务状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_route_id` (`route_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产任务';

-- ----------------------------
-- Table structure for mes_pro_task_issue  [mes]  来源：MesProTaskIssueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_task_issue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `source_doc_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据编号',
  `source_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行编号',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编码',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '投料批次',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '单位编号',
  `issued_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '总投料数量',
  `available_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '当前可用数量',
  `used_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '当前使用数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE,
  KEY `idx_source_line_id` (`source_line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产任务投料';

-- ----------------------------
-- Table structure for mes_pro_work_order  [mes]  来源：MesProWorkOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_work_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工单名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '工单类型',
  `order_source_type` int NOT NULL DEFAULT 0 COMMENT '来源类型',
  `order_source_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编号',
  `product_id` bigint NOT NULL DEFAULT 0 COMMENT '产品编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '生产数量',
  `quantity_produced` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已生产数量',
  `quantity_changed` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '调整数量',
  `quantity_scheduled` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '已排产数量',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `request_date` datetime NULL DEFAULT NULL COMMENT '需求日期',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父工单编号',
  `finish_date` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_date` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '工单状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产工单';

-- ----------------------------
-- Table structure for mes_pro_work_order_bom  [mes]  来源：MesProWorkOrderBomDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_work_order_bom`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT 'BOM 物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '预计使用量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产工单 BOM';

-- ----------------------------
-- Table structure for mes_pro_work_record  [mes]  来源：MesProWorkRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_work_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '当前状态',
  `clock_in_time` datetime NULL DEFAULT NULL COMMENT '上工时间',
  `clock_out_time` datetime NULL DEFAULT NULL COMMENT '下工时间',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 用户工作站绑定关系（当前快照）';

-- ----------------------------
-- Table structure for mes_pro_work_record_log  [mes]  来源：MesProWorkRecordLogDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_pro_work_record_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '操作类型',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 上下工记录流水';

-- ----------------------------
-- Table structure for mes_qc_defect  [mes]  来源：MesQcDefectDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_defect`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缺陷编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缺陷描述',
  `type` int NOT NULL DEFAULT 0 COMMENT '检测项类型',
  `level` int NOT NULL DEFAULT 0 COMMENT '缺陷等级',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 缺陷类型';

-- ----------------------------
-- Table structure for mes_qc_defect_record  [mes]  来源：MesQcDefectRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_defect_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `qc_type` int NOT NULL DEFAULT 0 COMMENT '检验类型',
  `qc_id` bigint NOT NULL DEFAULT 0 COMMENT '检验单 ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '检验行 ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缺陷描述',
  `level` int NOT NULL DEFAULT 0 COMMENT '缺陷等级',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '缺陷数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_qc_id` (`qc_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 质检缺陷记录';

-- ----------------------------
-- Table structure for mes_qc_indicator  [mes]  来源：MesQcIndicatorDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_indicator`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测项编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测项名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '检测项类型',
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测工具',
  `result_type` int NOT NULL DEFAULT 0 COMMENT '结果值类型',
  `result_specification` text NULL COMMENT '结果值属性',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 质检指标';

-- ----------------------------
-- Table structure for mes_qc_indicator_result  [mes]  来源：MesQcIndicatorResultDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_indicator_result`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样品编号',
  `qc_id` bigint NOT NULL DEFAULT 0 COMMENT '关联质检单 ID（IQC/IPQC/OQC/RQC 的 id）',
  `qc_type` int NOT NULL DEFAULT 0 COMMENT '质检类型',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物资 SN',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_qc_id` (`qc_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 检验结果记录';

-- ----------------------------
-- Table structure for mes_qc_indicator_result_detail  [mes]  来源：MesQcIndicatorResultDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_indicator_result_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `result_id` bigint NOT NULL DEFAULT 0 COMMENT '关联检验结果 ID',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '检测指标 ID',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测值（统一存为字符串）',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_result_id` (`result_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 检验结果明细记录';

-- ----------------------------
-- Table structure for mes_qc_ipqc  [mes]  来源：MesQcIpqcDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_ipqc`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单名称',
  `type` int NOT NULL DEFAULT 0 COMMENT 'IPQC 检验类型',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '检验模板 ID',
  `source_doc_type` int NOT NULL DEFAULT 0 COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编号（冗余）',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单 ID',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务 ID',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工位 ID',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `check_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '检测数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不合格品数量',
  `labor_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '工废数量',
  `material_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '料废数量',
  `other_scrap_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '其他废品数量',
  `critical_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '致命缺陷率（%）',
  `major_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '严重缺陷率（%）',
  `minor_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '轻微缺陷率（%）',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `check_result` int NOT NULL DEFAULT 0 COMMENT '检测结果',
  `inspect_date` datetime NULL DEFAULT NULL COMMENT '检测日期',
  `inspector_user_id` bigint NOT NULL DEFAULT 0 COMMENT '检测人员用户 ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE,
  KEY `idx_source_line_id` (`source_line_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_inspector_user_id` (`inspector_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 过程检验单（IPQC, In-Process Quality Control）';

-- ----------------------------
-- Table structure for mes_qc_ipqc_line  [mes]  来源：MesQcIpqcLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_ipqc_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `ipqc_id` bigint NOT NULL DEFAULT 0 COMMENT '过程检验单 ID',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '检测指标 ID',
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测工具',
  `check_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测方法',
  `standard_value` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '标准值',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位 ID',
  `max_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差上限',
  `min_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差下限',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_ipqc_id` (`ipqc_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 过程检验单行';

-- ----------------------------
-- Table structure for mes_qc_iqc  [mes]  来源：MesQcIqcDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_iqc`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单名称',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '检验模板 ID',
  `source_doc_type` int NOT NULL DEFAULT 0 COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编号（冗余）',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商 ID',
  `vendor_batch` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商批次号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `received_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次接收数量',
  `check_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次检测数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不合格品数量',
  `critical_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '致命缺陷率（%）',
  `major_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '严重缺陷率（%）',
  `minor_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '轻微缺陷率（%）',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `check_result` int NOT NULL DEFAULT 0 COMMENT '检测结果',
  `receive_date` datetime NULL DEFAULT NULL COMMENT '来料日期',
  `inspect_date` datetime NULL DEFAULT NULL COMMENT '检测日期',
  `inspector_user_id` bigint NOT NULL DEFAULT 0 COMMENT '检测人员用户 ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE,
  KEY `idx_source_line_id` (`source_line_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_inspector_user_id` (`inspector_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 来料检验单（IQC, Incoming Quality Control）';

-- ----------------------------
-- Table structure for mes_qc_iqc_line  [mes]  来源：MesQcIqcLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_iqc_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `iqc_id` bigint NOT NULL DEFAULT 0 COMMENT '来料检验单 ID',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '检测指标 ID',
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测工具',
  `check_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测方法',
  `standard_value` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '标准值',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位 ID',
  `max_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差上限',
  `min_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差下限',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_iqc_id` (`iqc_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 来料检验单行';

-- ----------------------------
-- Table structure for mes_qc_oqc  [mes]  来源：MesQcOqcDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_oqc`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单名称',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '检验模板 ID',
  `source_doc_type` int NOT NULL DEFAULT 0 COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编号（冗余）',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `min_check_quantity` int NOT NULL DEFAULT 0 COMMENT '最低检测数',
  `max_unqualified_quantity` int NOT NULL DEFAULT 0 COMMENT '最大不合格数',
  `out_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次出货数量',
  `check_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次检测数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不合格品数量',
  `critical_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '致命缺陷率（%）',
  `major_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '严重缺陷率（%）',
  `minor_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '轻微缺陷率（%）',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `check_result` int NOT NULL DEFAULT 0 COMMENT '检测结果',
  `out_date` datetime NULL DEFAULT NULL COMMENT '出货日期',
  `inspect_date` datetime NULL DEFAULT NULL COMMENT '检测日期',
  `inspector_user_id` bigint NOT NULL DEFAULT 0 COMMENT '检测人员用户 ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE,
  KEY `idx_source_line_id` (`source_line_id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_inspector_user_id` (`inspector_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 出货检验单（OQC, Outgoing Quality Control）';

-- ----------------------------
-- Table structure for mes_qc_oqc_line  [mes]  来源：MesQcOqcLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_oqc_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `oqc_id` bigint NOT NULL DEFAULT 0 COMMENT '出货检验单 ID',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '检测指标 ID',
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测工具',
  `check_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测方法',
  `standard_value` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '标准值',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位 ID',
  `max_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差上限',
  `min_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差下限',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_oqc_id` (`oqc_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 出货检验单行';

-- ----------------------------
-- Table structure for mes_qc_rqc  [mes]  来源：MesQcRqcDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_rqc`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检验单名称',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '检验模板 ID',
  `source_doc_type` int NOT NULL DEFAULT 0 COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编码（冗余）',
  `type` int NOT NULL DEFAULT 0 COMMENT '检验类型',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `check_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '检测数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格品数量',
  `unqualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '不合格数量',
  `critical_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '致命缺陷率（%）',
  `major_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '严重缺陷率（%）',
  `minor_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '轻微缺陷率（%）',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `check_result` int NOT NULL DEFAULT 0 COMMENT '检测结果',
  `inspect_date` datetime NULL DEFAULT NULL COMMENT '检测日期',
  `inspector_user_id` bigint NOT NULL DEFAULT 0 COMMENT '检测人员用户 ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE,
  KEY `idx_source_line_id` (`source_line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_inspector_user_id` (`inspector_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 退货检验单（RQC, Return Quality Control）';

-- ----------------------------
-- Table structure for mes_qc_rqc_line  [mes]  来源：MesQcRqcLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_rqc_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `rqc_id` bigint NOT NULL DEFAULT 0 COMMENT '退货检验单 ID',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '检测指标 ID',
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测工具',
  `check_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测方法',
  `standard_value` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '标准值',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位 ID',
  `max_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差上限',
  `min_threshold` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差下限',
  `critical_quantity` int NOT NULL DEFAULT 0 COMMENT '致命缺陷数量',
  `major_quantity` int NOT NULL DEFAULT 0 COMMENT '严重缺陷数量',
  `minor_quantity` int NOT NULL DEFAULT 0 COMMENT '轻微缺陷数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_rqc_id` (`rqc_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 退货检验行';

-- ----------------------------
-- Table structure for mes_qc_template  [mes]  来源：MesQcTemplateDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案名称',
  `types` text NULL COMMENT '检测种类',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 质检方案';

-- ----------------------------
-- Table structure for mes_qc_template_indicator  [mes]  来源：MesQcTemplateIndicatorDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_template_indicator`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '质检方案编号',
  `indicator_id` bigint NOT NULL DEFAULT 0 COMMENT '质检指标编号',
  `check_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '检测方法',
  `standard_value` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '标准值',
  `unit_measure_id` bigint NOT NULL DEFAULT 0 COMMENT '计量单位编号',
  `threshold_max` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差上限',
  `threshold_min` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '误差下限',
  `doc_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明图 URL',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_indicator_id` (`indicator_id`) USING BTREE,
  KEY `idx_unit_measure_id` (`unit_measure_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 质检方案-检测指标项';

-- ----------------------------
-- Table structure for mes_qc_template_item  [mes]  来源：MesQcTemplateItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_qc_template_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '质检方案编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `quantity_check` int NOT NULL DEFAULT 0 COMMENT '最低检测数',
  `quantity_unqualified` int NOT NULL DEFAULT 0 COMMENT '最大不合格数（0=不启用）',
  `critical_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最大致命缺陷率（%，0=不允许）',
  `major_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最大严重缺陷率（%，0=不允许）',
  `minor_rate` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最大轻微缺陷率（%）',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 质检方案-产品关联';

-- ----------------------------
-- Table structure for mes_tm_tool  [mes]  来源：MesTmToolDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_tm_tool`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具名称',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌',
  `specification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '型号规格',
  `tool_type_id` bigint NOT NULL DEFAULT 0 COMMENT '工具类型编号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量',
  `available_quantity` int NOT NULL DEFAULT 0 COMMENT '可用数量',
  `mainten_type` int NOT NULL DEFAULT 0 COMMENT '保养维护类型',
  `next_mainten_period` int NOT NULL DEFAULT 0 COMMENT '下次保养周期（次数）',
  `next_mainten_date` datetime NULL DEFAULT NULL COMMENT '下次保养日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_tool_type_id` (`tool_type_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工具台账';

-- ----------------------------
-- Table structure for mes_tm_tool_type  [mes]  来源：MesTmToolTypeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_tm_tool_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型名称',
  `code_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否编码管理',
  `mainten_type` int NOT NULL DEFAULT 0 COMMENT '保养维护类型',
  `mainten_period` int NOT NULL DEFAULT 0 COMMENT '保养周期',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 工具类型';

-- ----------------------------
-- Table structure for mes_wm_arrival_notice  [mes]  来源：MesWmArrivalNoticeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_arrival_notice`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通知单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通知单名称',
  `purchase_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单编号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `arrival_date` datetime NULL DEFAULT NULL COMMENT '到货日期',
  `contact_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 到货通知单';

-- ----------------------------
-- Table structure for mes_wm_arrival_notice_line  [mes]  来源：MesWmArrivalNoticeLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_arrival_notice_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `notice_id` bigint NOT NULL DEFAULT 0 COMMENT '到货通知单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `arrival_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '到货数量',
  `qualified_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '合格数量',
  `iqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否需要来料检验',
  `iqc_id` bigint NOT NULL DEFAULT 0 COMMENT '来料检验单编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_notice_id` (`notice_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_iqc_id` (`iqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 到货通知单行';

-- ----------------------------
-- Table structure for mes_wm_barcode  [mes]  来源：MesWmBarcodeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_barcode`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `config_id` bigint NOT NULL DEFAULT 0 COMMENT '条码配置编号',
  `format` int NOT NULL DEFAULT 0 COMMENT '条码格式',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `content` text NULL COMMENT '条码内容（核心字段，前端根据此内容生成条码图片）',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '业务编号',
  `biz_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务编码',
  `biz_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务名称',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_config_id` (`config_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 条码清单';

-- ----------------------------
-- Table structure for mes_wm_barcode_config  [mes]  来源：MesWmBarcodeConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_barcode_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `format` int NOT NULL DEFAULT 0 COMMENT '条码格式',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `content_format` text NULL COMMENT '内容格式模板（支持 {BUSINESSCODE} 占位符）',
  `content_example` text NULL COMMENT '内容样例',
  `auto_generate_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否自动生成',
  `default_template` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '默认打印模板',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 条码配置';

-- ----------------------------
-- Table structure for mes_wm_batch  [mes]  来源：MesWmBatchDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '批次ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次编码',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `produce_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '有效期',
  `receipt_date` datetime NULL DEFAULT NULL COMMENT '入库日期',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商ID',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户ID',
  `sales_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单编号',
  `purchase_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单ID',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务ID',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站ID',
  `tool_id` bigint NOT NULL DEFAULT 0 COMMENT '工具ID',
  `mold_id` bigint NOT NULL DEFAULT 0 COMMENT '模具 ID',
  `lot_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产批号',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_tool_id` (`tool_id`) USING BTREE,
  KEY `idx_mold_id` (`mold_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '批次管理';

-- ----------------------------
-- Table structure for mes_wm_item_consume  [mes]  来源：MesWmItemConsumeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_consume`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务编号',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站编号',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序编号',
  `feedback_id` bigint NOT NULL DEFAULT 0 COMMENT '报工记录编号',
  `consume_date` datetime NULL DEFAULT NULL COMMENT '消耗日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_feedback_id` (`feedback_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料消耗记录';

-- ----------------------------
-- Table structure for mes_wm_item_consume_detail  [mes]  来源：MesWmItemConsumeDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_consume_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `consume_id` bigint NOT NULL DEFAULT 0 COMMENT '消耗记录编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '消耗记录行编号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存台账编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '消耗数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_consume_id` (`consume_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料消耗记录明细';

-- ----------------------------
-- Table structure for mes_wm_item_consume_line  [mes]  来源：MesWmItemConsumeLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_consume_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `consume_id` bigint NOT NULL DEFAULT 0 COMMENT '消耗记录编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '消耗数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_consume_id` (`consume_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 物料消耗记录行';

-- ----------------------------
-- Table structure for mes_wm_item_receipt  [mes]  来源：MesWmItemReceiptDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单名称',
  `iqc_id` bigint NOT NULL DEFAULT 0 COMMENT '来料检验单编号',
  `notice_id` bigint NOT NULL DEFAULT 0 COMMENT '到货通知单编号',
  `purchase_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `receipt_date` datetime NULL DEFAULT NULL COMMENT '入库日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_iqc_id` (`iqc_id`) USING BTREE,
  KEY `idx_notice_id` (`notice_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 采购入库单';

-- ----------------------------
-- Table structure for mes_wm_item_receipt_detail  [mes]  来源：MesWmItemReceiptDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_receipt_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单行编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '上架数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 采购入库明细';

-- ----------------------------
-- Table structure for mes_wm_item_receipt_line  [mes]  来源：MesWmItemReceiptLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_item_receipt_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单编号',
  `arrival_notice_line_id` bigint NOT NULL DEFAULT 0 COMMENT '到货通知单行编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `received_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次编码',
  `production_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '有效期',
  `lot_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产批号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_arrival_notice_line_id` (`arrival_notice_line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 采购入库单行';

-- ----------------------------
-- Table structure for mes_wm_material_stock  [mes]  来源：MesWmMaterialStockDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_material_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `item_type_id` bigint NOT NULL DEFAULT 0 COMMENT '物料分类编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '在库数量',
  `receipt_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_item_type_id` (`item_type_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 库存台账（仓库现有量）';

-- ----------------------------
-- Table structure for mes_wm_misc_issue  [mes]  来源：MesWmMiscIssueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_issue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库单名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '杂项类型',
  `source_doc_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编号',
  `issue_date` datetime NULL DEFAULT NULL COMMENT '出库日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项出库单';

-- ----------------------------
-- Table structure for mes_wm_misc_issue_detail  [mes]  来源：MesWmMiscIssueDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_issue_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '出库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项出库明细';

-- ----------------------------
-- Table structure for mes_wm_misc_issue_line  [mes]  来源：MesWmMiscIssueLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_issue_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单编号',
  `source_doc_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据行ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '出库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_source_doc_line_id` (`source_doc_line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项出库单行';

-- ----------------------------
-- Table structure for mes_wm_misc_receipt  [mes]  来源：MesWmMiscReceiptDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '杂项类型',
  `source_doc_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据类型',
  `source_doc_id` bigint NOT NULL DEFAULT 0 COMMENT '来源单据 ID',
  `source_doc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单据编码',
  `receipt_date` datetime NULL DEFAULT NULL COMMENT '入库日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_source_doc_id` (`source_doc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项入库单';

-- ----------------------------
-- Table structure for mes_wm_misc_receipt_detail  [mes]  来源：MesWmMiscReceiptDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_receipt_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项入库明细';

-- ----------------------------
-- Table structure for mes_wm_misc_receipt_line  [mes]  来源：MesWmMiscReceiptLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_misc_receipt_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 杂项入库单行';

-- ----------------------------
-- Table structure for mes_wm_outsource_issue  [mes]  来源：MesWmOutsourceIssueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_issue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '发料单ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发料单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发料单名称',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商ID',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单ID',
  `issue_date` datetime NULL DEFAULT NULL COMMENT '发料日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '单据状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协发料单';

-- ----------------------------
-- Table structure for mes_wm_outsource_issue_detail  [mes]  来源：MesWmOutsourceIssueDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_issue_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行ID',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '发料单ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次ID',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库位ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库区ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协发料单明细';

-- ----------------------------
-- Table structure for mes_wm_outsource_issue_line  [mes]  来源：MesWmOutsourceIssueLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_issue_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '行ID',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '发料单ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '发料数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协发料单行';

-- ----------------------------
-- Table structure for mes_wm_outsource_receipt  [mes]  来源：MesWmOutsourceReceiptDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库单名称',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '外协工单编号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商编号',
  `receipt_date` datetime NULL DEFAULT NULL COMMENT '入库日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协入库单';

-- ----------------------------
-- Table structure for mes_wm_outsource_receipt_detail  [mes]  来源：MesWmOutsourceReceiptDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_receipt_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单行编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '上架数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协入库明细';

-- ----------------------------
-- Table structure for mes_wm_outsource_receipt_line  [mes]  来源：MesWmOutsourceReceiptLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_outsource_receipt_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `production_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '有效期',
  `lot_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产批号',
  `remark` text NULL COMMENT '备注',
  `iqc_id` bigint NOT NULL DEFAULT 0 COMMENT '来料检验单编号',
  `iqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否需要质检',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_iqc_id` (`iqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 外协入库单行';

-- ----------------------------
-- Table structure for mes_wm_package  [mes]  来源：MesWmPackageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_package`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '装箱单编号',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父箱 ID',
  `package_date` datetime NULL DEFAULT NULL COMMENT '装箱日期',
  `sales_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单编号',
  `invoice_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发票编号',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户 ID',
  `length` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '箱长度',
  `width` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '箱宽度',
  `height` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '箱高度',
  `size_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '尺寸单位 ID',
  `net_weight` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '净重',
  `gross_weight` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '毛重',
  `weight_unit_id` bigint NOT NULL DEFAULT 0 COMMENT '重量单位 ID',
  `inspector_user_id` bigint NOT NULL DEFAULT 0 COMMENT '检查员用户 ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE,
  KEY `idx_size_unit_id` (`size_unit_id`) USING BTREE,
  KEY `idx_weight_unit_id` (`weight_unit_id`) USING BTREE,
  KEY `idx_inspector_user_id` (`inspector_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 装箱单';

-- ----------------------------
-- Table structure for mes_wm_package_line  [mes]  来源：MesWmPackageLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_package_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `package_id` bigint NOT NULL DEFAULT 0 COMMENT '装箱单 ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '装箱数量',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单 ID',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '有效期',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_package_id` (`package_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 装箱明细';

-- ----------------------------
-- Table structure for mes_wm_product_issue  [mes]  来源：MesWmProductIssueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_issue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领料单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领料单名称',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站 ID',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单 ID',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务 ID',
  `issue_date` datetime NULL DEFAULT NULL COMMENT '领料日期',
  `required_time` datetime NULL DEFAULT NULL COMMENT '需求时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 领料出库单';

-- ----------------------------
-- Table structure for mes_wm_product_issue_detail  [mes]  来源：MesWmProductIssueDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_issue_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '领料单ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '领料数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 领料出库明细';

-- ----------------------------
-- Table structure for mes_wm_product_issue_line  [mes]  来源：MesWmProductIssueLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_issue_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '领料单 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '领料数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 领料出库单行';

-- ----------------------------
-- Table structure for mes_wm_product_produce  [mes]  来源：MesWmProductProduceDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_produce`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单 ID',
  `feedback_id` bigint NOT NULL DEFAULT 0 COMMENT '报工记录 ID',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '生产任务 ID',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站 ID',
  `process_id` bigint NOT NULL DEFAULT 0 COMMENT '工序 ID',
  `produce_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_feedback_id` (`feedback_id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产入库单';

-- ----------------------------
-- Table structure for mes_wm_product_produce_detail  [mes]  来源：MesWmProductProduceDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_produce_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `produce_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单 ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库 ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区 ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位 ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_produce_id` (`produce_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产入库明细';

-- ----------------------------
-- Table structure for mes_wm_product_produce_line  [mes]  来源：MesWmProductProduceLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_produce_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `produce_id` bigint NOT NULL DEFAULT 0 COMMENT '入库单 ID',
  `feedback_id` bigint NOT NULL DEFAULT 0 COMMENT '报工记录 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '入库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `expire_date` datetime NULL DEFAULT NULL COMMENT '过期日期',
  `lot_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产批号',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_produce_id` (`produce_id`) USING BTREE,
  KEY `idx_feedback_id` (`feedback_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产入库单行';

-- ----------------------------
-- Table structure for mes_wm_product_receipt  [mes]  来源：MesWmProductReceiptDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货单名称',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '产品物料编号',
  `receipt_date` datetime NULL DEFAULT NULL COMMENT '收货日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品收货（入库）单';

-- ----------------------------
-- Table structure for mes_wm_product_receipt_detail  [mes]  来源：MesWmProductReceiptDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_receipt_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '收货单行编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '收货单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '上架数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品收货（入库）单明细';

-- ----------------------------
-- Table structure for mes_wm_product_receipt_line  [mes]  来源：MesWmProductReceiptLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_receipt_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `receipt_id` bigint NOT NULL DEFAULT 0 COMMENT '收货单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存物资记录编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '收货数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_receipt_id` (`receipt_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 产品收货（入库）单行';

-- ----------------------------
-- Table structure for mes_wm_product_sales  [mes]  来源：MesWmProductSalesDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_sales`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库单号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库单名称',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户ID',
  `sales_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单号',
  `notice_id` bigint NOT NULL DEFAULT 0 COMMENT '发货通知单 ID',
  `sales_date` datetime NULL DEFAULT NULL COMMENT '出库日期',
  `contact_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货地址',
  `carrier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '承运商',
  `shipping_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '运输单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE,
  KEY `idx_notice_id` (`notice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售出库单';

-- ----------------------------
-- Table structure for mes_wm_product_sales_detail  [mes]  来源：MesWmProductSalesDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_sales_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单行ID',
  `sales_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '拣货数量',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录ID',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_sales_id` (`sales_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售出库明细';

-- ----------------------------
-- Table structure for mes_wm_product_sales_line  [mes]  来源：MesWmProductSalesLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_product_sales_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `sales_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ID',
  `notice_line_id` bigint NOT NULL DEFAULT 0 COMMENT '发货通知单行ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '出库数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录ID',
  `oqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否出厂检验',
  `oqc_id` bigint NOT NULL DEFAULT 0 COMMENT '出厂检验单 ID',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_sales_id` (`sales_id`) USING BTREE,
  KEY `idx_notice_line_id` (`notice_line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_oqc_id` (`oqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售出库单行';

-- ----------------------------
-- Table structure for mes_wm_return_issue  [mes]  来源：MesWmReturnIssueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_issue`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退料单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退料单名称',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单 ID',
  `workstation_id` bigint NOT NULL DEFAULT 0 COMMENT '工作站 ID',
  `type` int NOT NULL DEFAULT 0 COMMENT '退料类型',
  `return_date` datetime NULL DEFAULT NULL COMMENT '退料日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE,
  KEY `idx_workstation_id` (`workstation_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产退料单';

-- ----------------------------
-- Table structure for mes_wm_return_issue_detail  [mes]  来源：MesWmReturnIssueDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_issue_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '退料单 ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行 ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '退料数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库 ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区 ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位 ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产退料明细';

-- ----------------------------
-- Table structure for mes_wm_return_issue_line  [mes]  来源：MesWmReturnIssueLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_issue_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `issue_id` bigint NOT NULL DEFAULT 0 COMMENT '退料单 ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '退料数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次编码',
  `rqc_id` bigint NOT NULL DEFAULT 0 COMMENT '退货检验单 ID',
  `rqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否需要质检',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_issue_id` (`issue_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_rqc_id` (`rqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 生产退料单行';

-- ----------------------------
-- Table structure for mes_wm_return_sales  [mes]  来源：MesWmReturnSalesDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_sales`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货单名称',
  `sales_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单编号',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户 ID',
  `return_date` datetime NULL DEFAULT NULL COMMENT '退货日期',
  `return_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货原因',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售退货单';

-- ----------------------------
-- Table structure for mes_wm_return_sales_detail  [mes]  来源：MesWmReturnSalesDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_sales_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '退货单 ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库 ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区 ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位 ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售退货明细';

-- ----------------------------
-- Table structure for mes_wm_return_sales_line  [mes]  来源：MesWmReturnSalesLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_sales_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '退货单 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '退货数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `rqc_id` bigint NOT NULL DEFAULT 0 COMMENT '退货检验单 ID',
  `rqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否需要质检',
  `quality_status` int NOT NULL DEFAULT 0 COMMENT '质量状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_rqc_id` (`rqc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 销售退货单行';

-- ----------------------------
-- Table structure for mes_wm_return_vendor  [mes]  来源：MesWmReturnVendorDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_vendor`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货单名称',
  `purchase_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单编号',
  `vendor_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商 ID',
  `return_date` datetime NULL DEFAULT NULL COMMENT '退货日期',
  `return_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货原因',
  `transport_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流单号',
  `transport_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流联系电话',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_vendor_id` (`vendor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 供应商退货单';

-- ----------------------------
-- Table structure for mes_wm_return_vendor_detail  [mes]  来源：MesWmReturnVendorDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_vendor_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '退货单 ID',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '行 ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '退货数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库 ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区 ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位 ID',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 供应商退货明细';

-- ----------------------------
-- Table structure for mes_wm_return_vendor_line  [mes]  来源：MesWmReturnVendorLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_return_vendor_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `return_id` bigint NOT NULL DEFAULT 0 COMMENT '退货单 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '退货数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_return_id` (`return_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 供应商退货单行';

-- ----------------------------
-- Table structure for mes_wm_sales_notice  [mes]  来源：MesWmSalesNoticeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_sales_notice`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通知单编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通知单名称',
  `sales_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售订单编号',
  `client_id` bigint NOT NULL DEFAULT 0 COMMENT '客户编号',
  `sales_date` datetime NULL DEFAULT NULL COMMENT '发货日期',
  `recipient_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人',
  `recipient_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系方式',
  `recipient_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_client_id` (`client_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 发货通知单';

-- ----------------------------
-- Table structure for mes_wm_sales_notice_line  [mes]  来源：MesWmSalesNoticeLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_sales_notice_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `notice_id` bigint NOT NULL DEFAULT 0 COMMENT '发货通知单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '发货数量',
  `oqc_check_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否检验',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_notice_id` (`notice_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 发货通知单行';

-- ----------------------------
-- Table structure for mes_wm_sn  [mes]  来源：MesWmSnDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_sn`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次 UUID（用于标记同一批次生成的 SN 码）',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'SN 码（唯一）',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `work_order_id` bigint NOT NULL DEFAULT 0 COMMENT '生产工单编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_uuid` (`uuid`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_work_order_id` (`work_order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES SN 码';

-- ----------------------------
-- Table structure for mes_wm_stock_taking_plan  [mes]  来源：MesWmStockTakingPlanDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_stock_taking_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方案名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '盘点类型',
  `start_time` datetime NULL DEFAULT NULL COMMENT '计划开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '计划结束时间',
  `blind_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否盲盘',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结库存',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 盘点方案';

-- ----------------------------
-- Table structure for mes_wm_stock_taking_plan_param  [mes]  来源：MesWmStockTakingPlanParamDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_stock_taking_plan_param`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点方案编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '参数值类型',
  `value_id` bigint NOT NULL DEFAULT 0 COMMENT '参数值编号，例如仓库、库区、库位、物料、批次的主键 ID',
  `value_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参数值编码，例如仓库编码、库区编码、库位编码、物料编码、批次编码',
  `value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参数值名称，例如仓库名称、库区名称、库位名称、物料名称、批次名称',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_value_id` (`value_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 盘点方案参数';

-- ----------------------------
-- Table structure for mes_wm_stock_taking_task  [mes]  来源：MesWmStockTakingTaskDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_stock_taking_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务名称',
  `taking_date` datetime NULL DEFAULT NULL COMMENT '盘点日期',
  `type` int NOT NULL DEFAULT 0 COMMENT '盘点类型',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点人编号',
  `plan_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点计划编号',
  `blind_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否盲盘',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结库存',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '任务状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 盘点任务';

-- ----------------------------
-- Table structure for mes_wm_stock_taking_task_line  [mes]  来源：MesWmStockTakingTaskLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_stock_taking_task_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点任务编号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次编码',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '在库数量',
  `taking_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '盘点数量',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '盘点状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 盘点任务行';

-- ----------------------------
-- Table structure for mes_wm_stock_taking_task_result  [mes]  来源：MesWmStockTakingTaskResultDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_stock_taking_task_result`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点任务编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '盘点任务行编号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次编码',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库位编号',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '在库数量',
  `taking_quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '盘点数量',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 盘点结果';

-- ----------------------------
-- Table structure for mes_wm_transaction  [mes]  来源：MesWmTransactionDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_transaction`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '事务类型',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `biz_id` bigint NOT NULL DEFAULT 0 COMMENT '来源业务主单 ID',
  `biz_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源业务单号',
  `biz_line_id` bigint NOT NULL DEFAULT 0 COMMENT '来源业务行 ID',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录 ID',
  `related_transaction_id` bigint NOT NULL DEFAULT 0 COMMENT '关联的事务 ID',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料 ID',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '本次变动数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次 ID',
  `batch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库 ID',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区 ID',
  `area_id` bigint NOT NULL DEFAULT 0 COMMENT '库位 ID',
  `transaction_time` datetime NULL DEFAULT NULL COMMENT '事务发生时间',
  `erp_time` datetime NULL DEFAULT NULL COMMENT 'ERP 账期',
  `receipt_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE,
  KEY `idx_biz_line_id` (`biz_line_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_related_transaction_id` (`related_transaction_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 库存事务流水';

-- ----------------------------
-- Table structure for mes_wm_transfer  [mes]  来源：MesWmTransferDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_transfer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转移单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转移单名称',
  `type` int NOT NULL DEFAULT 0 COMMENT '转移单类型',
  `delivery_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否配送',
  `recipient_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人',
  `recipient_telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系方式',
  `destination_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '目的地',
  `carrier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '承运商',
  `shipping_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '运输单号',
  `confirm_flag` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否已确认',
  `transfer_date` datetime NULL DEFAULT NULL COMMENT '转移日期',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 转移单';

-- ----------------------------
-- Table structure for mes_wm_transfer_detail  [mes]  来源：MesWmTransferDetailDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_transfer_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `line_id` bigint NOT NULL DEFAULT 0 COMMENT '转移单行编号',
  `transfer_id` bigint NOT NULL DEFAULT 0 COMMENT '转移单编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '上架数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `to_warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '移入仓库编号',
  `to_location_id` bigint NOT NULL DEFAULT 0 COMMENT '移入库区编号',
  `to_area_id` bigint NOT NULL DEFAULT 0 COMMENT '移入库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_line_id` (`line_id`) USING BTREE,
  KEY `idx_transfer_id` (`transfer_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_to_warehouse_id` (`to_warehouse_id`) USING BTREE,
  KEY `idx_to_location_id` (`to_location_id`) USING BTREE,
  KEY `idx_to_area_id` (`to_area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 调拨明细';

-- ----------------------------
-- Table structure for mes_wm_transfer_line  [mes]  来源：MesWmTransferLineDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_transfer_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `transfer_id` bigint NOT NULL DEFAULT 0 COMMENT '转移单编号',
  `material_stock_id` bigint NOT NULL DEFAULT 0 COMMENT '库存记录编号',
  `item_id` bigint NOT NULL DEFAULT 0 COMMENT '物料编号',
  `quantity` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '转移数量',
  `batch_id` bigint NOT NULL DEFAULT 0 COMMENT '批次编号',
  `from_warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '移出仓库编号',
  `from_location_id` bigint NOT NULL DEFAULT 0 COMMENT '移出库区编号',
  `from_area_id` bigint NOT NULL DEFAULT 0 COMMENT '移出库位编号',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_transfer_id` (`transfer_id`) USING BTREE,
  KEY `idx_material_stock_id` (`material_stock_id`) USING BTREE,
  KEY `idx_item_id` (`item_id`) USING BTREE,
  KEY `idx_batch_id` (`batch_id`) USING BTREE,
  KEY `idx_from_warehouse_id` (`from_warehouse_id`) USING BTREE,
  KEY `idx_from_location_id` (`from_location_id`) USING BTREE,
  KEY `idx_from_area_id` (`from_area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 转移单行';

-- ----------------------------
-- Table structure for mes_wm_warehouse  [mes]  来源：MesWmWarehouseDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_warehouse`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `area` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '面积',
  `charge_user_id` bigint NOT NULL DEFAULT 0 COMMENT '负责人用户编号',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_charge_user_id` (`charge_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 仓库';

-- ----------------------------
-- Table structure for mes_wm_warehouse_area  [mes]  来源：MesWmWarehouseAreaDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_warehouse_area`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '库位编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '库位名称',
  `location_id` bigint NOT NULL DEFAULT 0 COMMENT '库区编号',
  `area` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '面积',
  `max_load` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '最大载重',
  `position_x` int NOT NULL DEFAULT 0 COMMENT '位置 X',
  `position_y` int NOT NULL DEFAULT 0 COMMENT '位置 Y',
  `position_z` int NOT NULL DEFAULT 0 COMMENT '位置 Z',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结',
  `allow_item_mixing` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否允许物料混放',
  `allow_batch_mixing` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否允许批次混放',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 库位';

-- ----------------------------
-- Table structure for mes_wm_warehouse_location  [mes]  来源：MesWmWarehouseLocationDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `mes_wm_warehouse_location`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '库区编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '库区名称',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库编号',
  `area` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '面积',
  `frozen` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否冻结',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MES 库区';

-- ----------------------------
-- Table structure for pay_app  [pay]  来源：PayAppDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_app`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '应用编号，数据库自增',
  `app_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用标识',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用名',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `remark` text NULL COMMENT '备注',
  `order_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付结果的回调地址',
  `refund_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退款结果的回调地址',
  `transfer_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账结果的回调地址',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付应用';

-- ----------------------------
-- Table structure for pay_channel  [pay]  来源：PayChannelDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_channel`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '渠道编号，数据库自增',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `fee_rate` double NOT NULL DEFAULT 0 COMMENT '渠道费率，单位：百分比',
  `remark` text NULL COMMENT '备注',
  `app_id` bigint NOT NULL DEFAULT 0 COMMENT '应用编号',
  `config` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付渠道配置',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付渠道';

-- ----------------------------
-- Table structure for pay_demo_order  [pay]  来源：PayDemoOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_demo_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单编号，自增',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品编号',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `price` int NOT NULL DEFAULT 0 COMMENT '价格，单位：分',
  `pay_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否支付',
  `pay_order_id` bigint NOT NULL DEFAULT 0 COMMENT '支付订单编号',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '付款时间',
  `pay_channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付渠道',
  `pay_refund_id` bigint NOT NULL DEFAULT 0 COMMENT '支付退款单号',
  `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '退款完成时间',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_pay_order_id` (`pay_order_id`) USING BTREE,
  KEY `idx_pay_refund_id` (`pay_refund_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '示例订单';

-- ----------------------------
-- Table structure for pay_demo_withdraw  [pay]  来源：PayDemoWithdrawDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_demo_withdraw`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '提现单编号，自增',
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '提现标题',
  `price` int NOT NULL DEFAULT 0 COMMENT '提现金额，单位：分',
  `user_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款人账号',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款人姓名',
  `type` int NOT NULL DEFAULT 0 COMMENT '提现方式',
  `status` int NOT NULL DEFAULT 0 COMMENT '提现状态',
  `pay_transfer_id` bigint NOT NULL DEFAULT 0 COMMENT '转账单编号',
  `transfer_channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账渠道',
  `transfer_time` datetime NULL DEFAULT NULL COMMENT '转账成功时间',
  `transfer_error_msg` text NULL COMMENT '转账错误提示',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_pay_transfer_id` (`pay_transfer_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '示例提现订单';

-- ----------------------------
-- Table structure for pay_notify_log  [pay]  来源：PayNotifyLogDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_notify_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志编号，自增',
  `task_id` bigint NOT NULL DEFAULT 0 COMMENT '通知任务编号',
  `notify_times` int NOT NULL DEFAULT 0 COMMENT '第几次被通知',
  `response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'HTTP 响应结果',
  `status` int NOT NULL DEFAULT 0 COMMENT '支付通知状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商户支付、退款等的通知 Log';

-- ----------------------------
-- Table structure for pay_notify_task  [pay]  来源：PayNotifyTaskDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_notify_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
  `app_id` bigint NOT NULL DEFAULT 0 COMMENT '应用编号',
  `type` int NOT NULL DEFAULT 0 COMMENT '通知类型',
  `data_id` bigint NOT NULL DEFAULT 0 COMMENT '数据编号，根据不同 type 进行关联：',
  `merchant_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户订单编号',
  `merchant_refund_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户退款编号',
  `merchant_transfer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户转账编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '通知状态',
  `next_notify_time` datetime NULL DEFAULT NULL COMMENT '下一次通知时间',
  `last_execute_time` datetime NULL DEFAULT NULL COMMENT '最后一次执行时间',
  `notify_times` int NOT NULL DEFAULT 0 COMMENT '当前通知次数',
  `max_notify_times` int NOT NULL DEFAULT 0 COMMENT '最大可通知次数',
  `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通知地址',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_id`) USING BTREE,
  KEY `idx_data_id` (`data_id`) USING BTREE,
  KEY `idx_merchant_order_id` (`merchant_order_id`) USING BTREE,
  KEY `idx_merchant_refund_id` (`merchant_refund_id`) USING BTREE,
  KEY `idx_merchant_transfer_id` (`merchant_transfer_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付通知';

-- ----------------------------
-- Table structure for pay_order  [pay]  来源：PayOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单编号，数据库自增',
  `app_id` bigint NOT NULL DEFAULT 0 COMMENT '应用编号',
  `channel_id` bigint NOT NULL DEFAULT 0 COMMENT '渠道编号',
  `channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型',
  `merchant_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户订单编号',
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品标题',
  `body` text NULL COMMENT '商品描述信息',
  `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异步通知地址',
  `price` int NOT NULL DEFAULT 0 COMMENT '支付金额，单位：分',
  `channel_fee_rate` double NOT NULL DEFAULT 0 COMMENT '渠道手续费，单位：百分比',
  `channel_fee_price` int NOT NULL DEFAULT 0 COMMENT '渠道手续金额，单位：分',
  `status` int NOT NULL DEFAULT 0 COMMENT '支付状态',
  `user_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '订单失效时间',
  `success_time` datetime NULL DEFAULT NULL COMMENT '订单支付成功时间',
  `extension_id` bigint NOT NULL DEFAULT 0 COMMENT '支付成功的订单拓展单编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付成功的外部订单号',
  `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款总金额，单位：分',
  `channel_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道用户编号',
  `channel_order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道订单号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_id`) USING BTREE,
  KEY `idx_channel_id` (`channel_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_merchant_order_id` (`merchant_order_id`) USING BTREE,
  KEY `idx_extension_id` (`extension_id`) USING BTREE,
  KEY `idx_channel_user_id` (`channel_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付订单';

-- ----------------------------
-- Table structure for pay_order_extension  [pay]  来源：PayOrderExtensionDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_order_extension`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单拓展编号，数据库自增',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部订单号，根据规则生成',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单号',
  `channel_id` bigint NOT NULL DEFAULT 0 COMMENT '渠道编号',
  `channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `user_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
  `status` int NOT NULL DEFAULT 0 COMMENT '支付状态',
  `channel_extras` text NULL COMMENT '支付渠道的额外参数',
  `channel_error_code` text NULL COMMENT '调用渠道的错误码',
  `channel_error_msg` text NULL COMMENT '调用渠道报错时，错误信息',
  `channel_notify_data` text NULL COMMENT '支付渠道的同步/异步通知的内容',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_channel_id` (`channel_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付订单拓展';

-- ----------------------------
-- Table structure for pay_refund  [pay]  来源：PayRefundDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_refund`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '退款单编号，数据库自增',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部退款号，根据规则生成',
  `app_id` bigint NOT NULL DEFAULT 0 COMMENT '应用编号',
  `channel_id` bigint NOT NULL DEFAULT 0 COMMENT '渠道编号',
  `channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付订单编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型',
  `merchant_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户订单编号',
  `merchant_refund_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户退款订单号',
  `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异步通知地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '退款状态',
  `pay_price` int NOT NULL DEFAULT 0 COMMENT '支付金额，单位：分',
  `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退款原因',
  `user_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
  `channel_order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道订单号',
  `channel_refund_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道退款单号',
  `success_time` datetime NULL DEFAULT NULL COMMENT '退款成功时间',
  `channel_error_code` text NULL COMMENT '调用渠道的错误码',
  `channel_error_msg` text NULL COMMENT '调用渠道的错误提示',
  `channel_notify_data` text NULL COMMENT '支付渠道的同步/异步通知的内容',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_id`) USING BTREE,
  KEY `idx_channel_id` (`channel_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_merchant_order_id` (`merchant_order_id`) USING BTREE,
  KEY `idx_merchant_refund_id` (`merchant_refund_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付退款单';

-- ----------------------------
-- Table structure for pay_transfer  [pay]  来源：PayTransferDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_transfer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账单号',
  `app_id` bigint NOT NULL DEFAULT 0 COMMENT '应用编号',
  `channel_id` bigint NOT NULL DEFAULT 0 COMMENT '转账渠道编号',
  `channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账渠道编码',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型',
  `merchant_transfer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户转账单编号',
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账标题',
  `price` int NOT NULL DEFAULT 0 COMMENT '转账金额，单位：分',
  `user_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款人账号',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款人姓名',
  `status` int NOT NULL DEFAULT 0 COMMENT '转账状态',
  `success_time` datetime NULL DEFAULT NULL COMMENT '订单转账成功时间',
  `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异步通知地址',
  `user_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
  `channel_extras` text NULL COMMENT '渠道的额外参数',
  `channel_transfer_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道转账单号',
  `channel_error_code` text NULL COMMENT '调用渠道的错误码',
  `channel_error_msg` text NULL COMMENT '调用渠道的错误提示',
  `channel_notify_data` text NULL COMMENT '渠道的同步/异步通知的内容',
  `channel_package_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道 package 信息',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_id`) USING BTREE,
  KEY `idx_channel_id` (`channel_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_merchant_transfer_id` (`merchant_transfer_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '转账单';

-- ----------------------------
-- Table structure for pay_wallet  [pay]  来源：PayWalletDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_wallet`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户 id',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型, 预留 多商户转帐可能需要用到',
  `balance` int NOT NULL DEFAULT 0 COMMENT '余额，单位分',
  `freeze_price` int NOT NULL DEFAULT 0 COMMENT '冻结金额，单位分',
  `total_expense` int NOT NULL DEFAULT 0 COMMENT '累计支出，单位分',
  `total_recharge` int NOT NULL DEFAULT 0 COMMENT '累计充值，单位分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员钱包';

-- ----------------------------
-- Table structure for pay_wallet_recharge  [pay]  来源：PayWalletRechargeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_wallet_recharge`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `wallet_id` bigint NOT NULL DEFAULT 0 COMMENT '钱包编号',
  `total_price` int NOT NULL DEFAULT 0 COMMENT '用户实际到账余额',
  `pay_price` int NOT NULL DEFAULT 0 COMMENT '实际支付金额',
  `bonus_price` int NOT NULL DEFAULT 0 COMMENT '钱包赠送金额',
  `package_id` bigint NOT NULL DEFAULT 0 COMMENT '充值套餐编号',
  `pay_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否已支付',
  `pay_order_id` bigint NOT NULL DEFAULT 0 COMMENT '支付订单编号',
  `pay_channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付成功的支付渠道',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '订单支付时间',
  `pay_refund_id` bigint NOT NULL DEFAULT 0 COMMENT '支付退款单编号',
  `refund_total_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，包含赠送金额',
  `refund_pay_price` int NOT NULL DEFAULT 0 COMMENT '退款支付金额',
  `refund_bonus_price` int NOT NULL DEFAULT 0 COMMENT '退款钱包赠送金额',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `refund_status` int NOT NULL DEFAULT 0 COMMENT '退款状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_wallet_id` (`wallet_id`) USING BTREE,
  KEY `idx_package_id` (`package_id`) USING BTREE,
  KEY `idx_pay_order_id` (`pay_order_id`) USING BTREE,
  KEY `idx_pay_refund_id` (`pay_refund_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员钱包充值';

-- ----------------------------
-- Table structure for pay_wallet_recharge_package  [pay]  来源：PayWalletRechargePackageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_wallet_recharge_package`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '套餐名',
  `pay_price` int NOT NULL DEFAULT 0 COMMENT '支付金额',
  `bonus_price` int NOT NULL DEFAULT 0 COMMENT '赠送金额',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员钱包充值套餐';

-- ----------------------------
-- Table structure for pay_wallet_transaction  [pay]  来源：PayWalletTransactionDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_wallet_transaction`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流水号',
  `wallet_id` bigint NOT NULL DEFAULT 0 COMMENT '钱包编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '关联业务分类',
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联业务编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流水说明',
  `price` int NOT NULL DEFAULT 0 COMMENT '交易金额，单位分',
  `balance` int NOT NULL DEFAULT 0 COMMENT '交易后余额，单位分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_wallet_id` (`wallet_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员钱包流水';

-- ----------------------------
-- Table structure for product_brand  [product]  来源：ProductBrandDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_brand`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '品牌编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌图片',
  `sort` int NOT NULL DEFAULT 0 COMMENT '品牌排序',
  `description` text NULL COMMENT '品牌描述',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品品牌';

-- ----------------------------
-- Table structure for product_browse_history  [product]  来源：ProductBrowseHistoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_browse_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '用户是否删除',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品浏览记录';

-- ----------------------------
-- Table structure for product_category  [product]  来源：ProductCategoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类编号',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父分类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类名称',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '移动端分类图',
  `sort` int NOT NULL DEFAULT 0 COMMENT '分类排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '开启状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品分类';

-- ----------------------------
-- Table structure for product_comment  [product]  来源：ProductCommentDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论编号，主键自增',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '评价人的用户编号',
  `user_nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价人名称',
  `user_avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价人头像',
  `anonymous` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否匿名',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '交易订单编号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '交易订单项编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品 SPU 名称',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `sku_pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品 SKU 图片地址',
  `sku_properties` text NULL COMMENT '属性数组，JSON 格式',
  `visible` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否可见',
  `scores` int NOT NULL DEFAULT 0 COMMENT '评分星级',
  `description_scores` int NOT NULL DEFAULT 0 COMMENT '描述星级',
  `benefit_scores` int NOT NULL DEFAULT 0 COMMENT '服务星级',
  `content` text NULL COMMENT '评论内容',
  `pic_urls` text NULL COMMENT '评论图片地址数组',
  `reply_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '商家是否回复',
  `reply_user_id` bigint NOT NULL DEFAULT 0 COMMENT '回复管理员编号',
  `reply_content` text NULL COMMENT '商家回复内容',
  `reply_time` datetime NULL DEFAULT NULL COMMENT '商家回复时间',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE,
  KEY `idx_reply_user_id` (`reply_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品评论';

-- ----------------------------
-- Table structure for product_favorite  [product]  来源：ProductFavoriteDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品收藏';

-- ----------------------------
-- Table structure for product_property  [product]  来源：ProductPropertyDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_property`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品属性项';

-- ----------------------------
-- Table structure for product_property_value  [product]  来源：ProductPropertyValueDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_property_value`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `property_id` bigint NOT NULL DEFAULT 0 COMMENT '属性项的编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_property_id` (`property_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品属性值';

-- ----------------------------
-- Table structure for product_sku  [product]  来源：ProductSkuDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商品 SKU 编号，自增',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT 'SPU 编号',
  `properties` text NULL COMMENT '属性数组，JSON 格式',
  `price` int NOT NULL DEFAULT 0 COMMENT '商品价格，单位：分',
  `market_price` int NOT NULL DEFAULT 0 COMMENT '市场价，单位：分',
  `cost_price` int NOT NULL DEFAULT 0 COMMENT '成本价，单位：分',
  `bar_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品条码',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片地址',
  `stock` int NOT NULL DEFAULT 0 COMMENT '库存',
  `weight` double NOT NULL DEFAULT 0 COMMENT '商品重量，单位：kg 千克',
  `volume` double NOT NULL DEFAULT 0 COMMENT '商品体积，单位：m^3 平米',
  `first_brokerage_price` int NOT NULL DEFAULT 0 COMMENT '一级分销的佣金，单位：分',
  `second_brokerage_price` int NOT NULL DEFAULT 0 COMMENT '二级分销的佣金，单位：分',
  `sales_count` int NOT NULL DEFAULT 0 COMMENT '商品销量',
  `property_id` bigint NOT NULL DEFAULT 0 COMMENT '属性编号',
  `property_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性名字',
  `value_id` bigint NOT NULL DEFAULT 0 COMMENT '属性值编号',
  `value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性值名字',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_property_id` (`property_id`) USING BTREE,
  KEY `idx_value_id` (`value_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品 SKU';

-- ----------------------------
-- Table structure for product_spu  [product]  来源：ProductSpuDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_spu`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商品 SPU 编号，自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `keyword` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关键字',
  `introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品简介',
  `description` text NULL COMMENT '商品详情',
  `category_id` bigint NOT NULL DEFAULT 0 COMMENT '商品分类编号',
  `brand_id` bigint NOT NULL DEFAULT 0 COMMENT '商品品牌编号',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品封面图',
  `slider_pic_urls` text NULL COMMENT '商品轮播图',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序字段',
  `status` int NOT NULL DEFAULT 0 COMMENT '商品状态',
  `spec_type` bit(1) NOT NULL DEFAULT b'0' COMMENT '规格类型',
  `price` int NOT NULL DEFAULT 0 COMMENT '商品价格，单位使用：分',
  `market_price` int NOT NULL DEFAULT 0 COMMENT '市场价，单位使用：分',
  `cost_price` int NOT NULL DEFAULT 0 COMMENT '成本价，单位使用：分',
  `stock` int NOT NULL DEFAULT 0 COMMENT '库存',
  `delivery_types` text NULL COMMENT '配送方式数组',
  `delivery_template_id` bigint NOT NULL DEFAULT 0 COMMENT '物流配置模板编号',
  `give_integral` int NOT NULL DEFAULT 0 COMMENT '赠送积分',
  `sub_commission_type` bit(1) NOT NULL DEFAULT b'0' COMMENT '分销类型',
  `sales_count` int NOT NULL DEFAULT 0 COMMENT '商品销量',
  `virtual_sales_count` int NOT NULL DEFAULT 0 COMMENT '虚拟销量',
  `browse_count` int NOT NULL DEFAULT 0 COMMENT '浏览量',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_category_id` (`category_id`) USING BTREE,
  KEY `idx_brand_id` (`brand_id`) USING BTREE,
  KEY `idx_delivery_template_id` (`delivery_template_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品 SPU';

-- ----------------------------
-- Table structure for promotion_article  [promotion]  来源：ArticleDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_article`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文章管理编号',
  `category_id` bigint NOT NULL DEFAULT 0 COMMENT '分类编号 ArticleCategoryDO#id',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '关联商品编号 ProductSpuDO#id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文章标题',
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文章作者',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文章封面图片地址',
  `introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文章简介',
  `browse_count` int NOT NULL DEFAULT 0 COMMENT '浏览次数',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `recommend_hot` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否热门(小程序)',
  `recommend_banner` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否轮播图(小程序)',
  `content` text NULL COMMENT '文章内容',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_category_id` (`category_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文章管理';

-- ----------------------------
-- Table structure for promotion_article_category  [promotion]  来源：ArticleCategoryDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_article_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文章分类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文章分类名称',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文章分类';

-- ----------------------------
-- Table structure for promotion_banner  [promotion]  来源：BannerDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_banner`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '跳转链接',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片链接',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态 {@link CommonStatusEnum}',
  `position` int NOT NULL DEFAULT 0 COMMENT '定位 {@link BannerPositionEnum}',
  `memo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `browse_count` int NOT NULL DEFAULT 0 COMMENT '点击次数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'banner';

-- ----------------------------
-- Table structure for promotion_bargain_activity  [promotion]  来源：BargainActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_bargain_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '砍价活动编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '砍价活动名称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '活动开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '活动结束时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '活动状态',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `bargain_first_price` int NOT NULL DEFAULT 0 COMMENT '砍价起始价格，单位：分',
  `bargain_min_price` int NOT NULL DEFAULT 0 COMMENT '砍价底价，单位：分',
  `stock` int NOT NULL DEFAULT 0 COMMENT '砍价库存(剩余库存砍价时扣减)',
  `total_stock` int NOT NULL DEFAULT 0 COMMENT '砍价总库存',
  `help_max_count` int NOT NULL DEFAULT 0 COMMENT '砍价人数',
  `bargain_count` int NOT NULL DEFAULT 0 COMMENT '帮砍次数',
  `total_limit_count` int NOT NULL DEFAULT 0 COMMENT '总限购数量',
  `random_min_price` int NOT NULL DEFAULT 0 COMMENT '用户每次砍价的最小金额，单位：分',
  `random_max_price` int NOT NULL DEFAULT 0 COMMENT '用户每次砍价的最大金额，单位：分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '砍价活动';

-- ----------------------------
-- Table structure for promotion_bargain_help  [promotion]  来源：BargainHelpDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_bargain_help`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '砍价活动编号',
  `record_id` bigint NOT NULL DEFAULT 0 COMMENT '砍价记录编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `reduce_price` int NOT NULL DEFAULT 0 COMMENT '减少价格，单位：分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_record_id` (`record_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '砍价助力';

-- ----------------------------
-- Table structure for promotion_bargain_record  [promotion]  来源：BargainRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_bargain_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '砍价活动编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `bargain_first_price` int NOT NULL DEFAULT 0 COMMENT '砍价起始价格，单位：分',
  `bargain_price` int NOT NULL DEFAULT 0 COMMENT '当前砍价，单位：分',
  `status` int NOT NULL DEFAULT 0 COMMENT '砍价状态',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '砍价记录 DO TO';

-- ----------------------------
-- Table structure for promotion_combination_activity  [promotion]  来源：CombinationActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_combination_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拼团名称',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `total_limit_count` int NOT NULL DEFAULT 0 COMMENT '总限购数量',
  `single_limit_count` int NOT NULL DEFAULT 0 COMMENT '单次限购数量',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `user_size` int NOT NULL DEFAULT 0 COMMENT '几人团',
  `virtual_group` bit(1) NOT NULL DEFAULT b'0' COMMENT '虚拟成团',
  `status` int NOT NULL DEFAULT 0 COMMENT '活动状态',
  `limit_duration` int NOT NULL DEFAULT 0 COMMENT '限制时长（小时）',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '拼团活动';

-- ----------------------------
-- Table structure for promotion_combination_product  [promotion]  来源：CombinationProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_combination_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '拼团活动编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `combination_price` int NOT NULL DEFAULT 0 COMMENT '拼团价格，单位分',
  `activity_status` int NOT NULL DEFAULT 0 COMMENT '拼团商品状态',
  `activity_start_time` datetime NULL DEFAULT NULL COMMENT '活动开始时间点',
  `activity_end_time` datetime NULL DEFAULT NULL COMMENT '活动结束时间点',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '拼团商品';

-- ----------------------------
-- Table structure for promotion_combination_record  [promotion]  来源：CombinationRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_combination_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '拼团活动编号',
  `combination_price` int NOT NULL DEFAULT 0 COMMENT '拼团商品单价',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT 'SPU 编号',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名字',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT 'SKU 编号',
  `count` int NOT NULL DEFAULT 0 COMMENT '购买的商品数量',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户头像',
  `head_id` bigint NOT NULL DEFAULT 0 COMMENT '团长编号',
  `status` int NOT NULL DEFAULT 0 COMMENT '开团状态',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单编号',
  `user_size` int NOT NULL DEFAULT 0 COMMENT '开团需要人数',
  `user_count` int NOT NULL DEFAULT 0 COMMENT '已加入拼团人数',
  `virtual_group` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否虚拟成团',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间 (订单付款后开始的时间)',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间（成团时间/失败时间）',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_head_id` (`head_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '拼团记录';

-- ----------------------------
-- Table structure for promotion_coupon  [promotion]  来源：CouponDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_coupon`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '优惠劵编号',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '优惠劵模板编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠劵名',
  `status` int NOT NULL DEFAULT 0 COMMENT '优惠码状态',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `take_type` int NOT NULL DEFAULT 0 COMMENT '领取类型',
  `use_price` int NOT NULL DEFAULT 0 COMMENT '是否设置满多少金额可用，单位：分',
  `valid_start_time` datetime NULL DEFAULT NULL COMMENT '生效开始时间',
  `valid_end_time` datetime NULL DEFAULT NULL COMMENT '生效结束时间',
  `product_scope` int NOT NULL DEFAULT 0 COMMENT '商品范围',
  `product_scope_values` text NULL COMMENT '商品范围编号的数组',
  `discount_type` int NOT NULL DEFAULT 0 COMMENT '折扣类型',
  `discount_percent` int NOT NULL DEFAULT 0 COMMENT '折扣百分比',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：分',
  `discount_limit_price` int NOT NULL DEFAULT 0 COMMENT '折扣上限，仅在 {@link #discountType} 等于 {@link PromotionDiscountTypeEnum#PERCENT} 时生效',
  `use_order_id` bigint NOT NULL DEFAULT 0 COMMENT '使用订单号',
  `use_time` datetime NULL DEFAULT NULL COMMENT '使用时间',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_use_order_id` (`use_order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠劵';

-- ----------------------------
-- Table structure for promotion_coupon_template  [promotion]  来源：CouponTemplateDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_coupon_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板编号，自增唯一',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠劵名',
  `description` text NULL COMMENT '优惠券说明',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '发放数量',
  `take_limit_count` int NOT NULL DEFAULT 0 COMMENT '每人限领个数',
  `take_type` int NOT NULL DEFAULT 0 COMMENT '领取方式',
  `use_price` int NOT NULL DEFAULT 0 COMMENT '是否设置满多少金额可用，单位：分',
  `product_scope` int NOT NULL DEFAULT 0 COMMENT '商品范围',
  `product_scope_values` text NULL COMMENT '商品范围编号的数组',
  `validity_type` int NOT NULL DEFAULT 0 COMMENT '生效日期类型',
  `valid_start_time` datetime NULL DEFAULT NULL COMMENT '固定日期 - 生效开始时间',
  `valid_end_time` datetime NULL DEFAULT NULL COMMENT '固定日期 - 生效结束时间',
  `fixed_start_term` int NOT NULL DEFAULT 0 COMMENT '领取日期 - 开始天数',
  `fixed_end_term` int NOT NULL DEFAULT 0 COMMENT '领取日期 - 结束天数',
  `discount_type` int NOT NULL DEFAULT 0 COMMENT '折扣类型',
  `discount_percent` int NOT NULL DEFAULT 0 COMMENT '折扣百分比',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：分',
  `discount_limit_price` int NOT NULL DEFAULT 0 COMMENT '折扣上限，仅在 {@link #discountType} 等于 {@link PromotionDiscountTypeEnum#PERCENT} 时生效',
  `take_count` int NOT NULL DEFAULT 0 COMMENT '领取优惠券的数量',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '使用优惠券的次数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠劵模板';

-- ----------------------------
-- Table structure for promotion_discount_activity  [promotion]  来源：DiscountActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_discount_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动编号，主键自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动标题',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `remark` text NULL COMMENT '备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '限时折扣活动';

-- ----------------------------
-- Table structure for promotion_discount_product  [promotion]  来源：DiscountProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_discount_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '限时折扣活动的编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `discount_type` int NOT NULL DEFAULT 0 COMMENT '折扣类型',
  `discount_percent` int NOT NULL DEFAULT 0 COMMENT '折扣百分比',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：分',
  `activity_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动标题',
  `activity_status` int NOT NULL DEFAULT 0 COMMENT '活动状态',
  `activity_start_time` datetime NULL DEFAULT NULL COMMENT '活动开始时间点',
  `activity_end_time` datetime NULL DEFAULT NULL COMMENT '活动结束时间点',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '限时折扣商品';

-- ----------------------------
-- Table structure for promotion_diy_page  [promotion]  来源：DiyPageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_diy_page`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '装修页面编号',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '装修模板编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '页面名称',
  `remark` text NULL COMMENT '备注',
  `preview_pic_urls` text NULL COMMENT '预览图，多个逗号分隔',
  `property` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '页面属性，JSON 格式',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '装修页面';

-- ----------------------------
-- Table structure for promotion_diy_template  [promotion]  来源：DiyTemplateDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_diy_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '装修模板编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模板名称',
  `used` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否使用',
  `used_time` datetime NULL DEFAULT NULL COMMENT '使用时间',
  `remark` text NULL COMMENT '备注',
  `preview_pic_urls` text NULL COMMENT '预览图',
  `property` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'uni-app 底部导航属性，JSON 格式',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '装修模板';

-- ----------------------------
-- Table structure for promotion_kefu_conversation  [promotion]  来源：KeFuConversationDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_kefu_conversation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '会话所属用户',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后聊天时间',
  `last_message_content` text NULL COMMENT '最后聊天内容',
  `last_message_content_type` int NOT NULL DEFAULT 0 COMMENT '最后发送的消息类型',
  `admin_pinned` bit(1) NOT NULL DEFAULT b'0' COMMENT '管理端置顶',
  `user_deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '用户是否可见',
  `admin_deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '管理员是否可见',
  `admin_unread_message_count` int NOT NULL DEFAULT 0 COMMENT '管理员未读消息数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '客服会话';

-- ----------------------------
-- Table structure for promotion_kefu_message  [promotion]  来源：KeFuMessageDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_kefu_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `conversation_id` bigint NOT NULL DEFAULT 0 COMMENT '会话编号',
  `sender_id` bigint NOT NULL DEFAULT 0 COMMENT '发送人编号',
  `sender_type` int NOT NULL DEFAULT 0 COMMENT '发送人类型',
  `receiver_id` bigint NOT NULL DEFAULT 0 COMMENT '接收人编号',
  `receiver_type` int NOT NULL DEFAULT 0 COMMENT '接收人类型',
  `content_type` int NOT NULL DEFAULT 0 COMMENT '消息类型',
  `content` text NULL COMMENT '消息',
  `read_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是/否已读',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_conversation_id` (`conversation_id`) USING BTREE,
  KEY `idx_sender_id` (`sender_id`) USING BTREE,
  KEY `idx_receiver_id` (`receiver_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '客服消息';

-- ----------------------------
-- Table structure for promotion_point_activity  [promotion]  来源：PointActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_point_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '积分商城活动编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '积分商城活动商品',
  `status` int NOT NULL DEFAULT 0 COMMENT '活动状态',
  `remark` text NULL COMMENT '备注',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `stock` int NOT NULL DEFAULT 0 COMMENT '积分商城活动库存(剩余库存积分兑换时扣减)',
  `total_stock` int NOT NULL DEFAULT 0 COMMENT '积分商城活动总库存',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '积分商城活动';

-- ----------------------------
-- Table structure for promotion_point_product  [promotion]  来源：PointProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_point_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '积分商城商品编号',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '积分商城活动 id',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `count` int NOT NULL DEFAULT 0 COMMENT '可兑换次数',
  `point` int NOT NULL DEFAULT 0 COMMENT '所需兑换积分',
  `price` int NOT NULL DEFAULT 0 COMMENT '所需兑换金额，单位：分',
  `stock` int NOT NULL DEFAULT 0 COMMENT '积分商城商品库存',
  `activity_status` int NOT NULL DEFAULT 0 COMMENT '积分商城商品状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '积分商城商品';

-- ----------------------------
-- Table structure for promotion_reward_activity  [promotion]  来源：RewardActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_reward_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动编号，主键自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动标题',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `remark` text NULL COMMENT '备注',
  `condition_type` int NOT NULL DEFAULT 0 COMMENT '条件类型',
  `product_scope` int NOT NULL DEFAULT 0 COMMENT '商品范围',
  `product_scope_values` text NULL COMMENT '商品 SPU 编号的数组',
  `rules` text NULL COMMENT '优惠规则的数组',
  `limit` int NOT NULL DEFAULT 0 COMMENT '优惠门槛',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠价格，单位：分',
  `free_delivery` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否包邮',
  `point` int NOT NULL DEFAULT 0 COMMENT '赠送的积分',
  `give_coupon_template_counts` text NULL COMMENT '赠送的优惠劵',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '满减送活动';

-- ----------------------------
-- Table structure for promotion_seckill_activity  [promotion]  来源：SeckillActivityDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_seckill_activity`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '秒杀活动编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '秒杀活动商品',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '秒杀活动名称',
  `status` int NOT NULL DEFAULT 0 COMMENT '活动状态',
  `remark` text NULL COMMENT '备注',
  `start_time` datetime NULL DEFAULT NULL COMMENT '活动开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '活动结束时间',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `config_ids` text NULL COMMENT '秒杀时段 id',
  `total_limit_count` int NOT NULL DEFAULT 0 COMMENT '总限购数量',
  `single_limit_count` int NOT NULL DEFAULT 0 COMMENT '单次限够数量',
  `stock` int NOT NULL DEFAULT 0 COMMENT '秒杀库存(剩余库存秒杀时扣减)',
  `total_stock` int NOT NULL DEFAULT 0 COMMENT '秒杀总库存',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '秒杀活动';

-- ----------------------------
-- Table structure for promotion_seckill_config  [promotion]  来源：SeckillConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_seckill_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '秒杀时段名称',
  `start_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开始时间点',
  `end_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结束时间点',
  `slider_pic_urls` text NULL COMMENT '秒杀轮播图',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '秒杀时段';

-- ----------------------------
-- Table structure for promotion_seckill_product  [promotion]  来源：SeckillProductDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `promotion_seckill_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '秒杀参与商品编号',
  `activity_id` bigint NOT NULL DEFAULT 0 COMMENT '秒杀活动 id',
  `config_ids` text NULL COMMENT '秒杀时段 id',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `seckill_price` int NOT NULL DEFAULT 0 COMMENT '秒杀金额，单位：分',
  `stock` int NOT NULL DEFAULT 0 COMMENT '秒杀库存',
  `activity_status` int NOT NULL DEFAULT 0 COMMENT '秒杀商品状态',
  `activity_start_time` datetime NULL DEFAULT NULL COMMENT '活动开始时间点',
  `activity_end_time` datetime NULL DEFAULT NULL COMMENT '活动结束时间点',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_activity_id` (`activity_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '秒杀参与商品';

-- ----------------------------
-- Table structure for report_go_view_project  [report]  来源：GoViewProjectDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `report_go_view_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，数据库自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目名称',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预览图片 URL',
  `content` text NULL COMMENT '报表内容',
  `status` int NOT NULL DEFAULT 0 COMMENT '发布状态',
  `remark` text NULL COMMENT '项目备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'GoView 项目表';

-- ----------------------------
-- Table structure for product_statistics  [statistics]  来源：ProductStatisticsDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `product_statistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `time` date CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '统计日期',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `browse_count` int NOT NULL DEFAULT 0 COMMENT '浏览量',
  `browse_user_count` int NOT NULL DEFAULT 0 COMMENT '访客量',
  `favorite_count` int NOT NULL DEFAULT 0 COMMENT '收藏数量',
  `cart_count` int NOT NULL DEFAULT 0 COMMENT '加购数量',
  `order_count` int NOT NULL DEFAULT 0 COMMENT '下单件数',
  `order_pay_count` int NOT NULL DEFAULT 0 COMMENT '支付件数',
  `order_pay_price` int NOT NULL DEFAULT 0 COMMENT '支付金额，单位：分',
  `after_sale_count` int NOT NULL DEFAULT 0 COMMENT '退款件数',
  `after_sale_refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分',
  `browse_convert_percent` int NOT NULL DEFAULT 0 COMMENT '访客支付转化率（百分比）',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品统计';

-- ----------------------------
-- Table structure for trade_statistics  [statistics]  来源：TradeStatisticsDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_statistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
  `time` datetime NULL DEFAULT NULL COMMENT '统计日期',
  `order_create_count` int NOT NULL DEFAULT 0 COMMENT '创建订单数',
  `order_pay_count` int NOT NULL DEFAULT 0 COMMENT '支付订单商品数',
  `order_pay_price` int NOT NULL DEFAULT 0 COMMENT '总支付金额，单位：分',
  `after_sale_count` int NOT NULL DEFAULT 0 COMMENT '退款订单数',
  `after_sale_refund_price` int NOT NULL DEFAULT 0 COMMENT '总退款金额，单位：分',
  `brokerage_settlement_price` int NOT NULL DEFAULT 0 COMMENT '佣金金额（已结算），单位：分',
  `wallet_pay_price` int NOT NULL DEFAULT 0 COMMENT '总支付金额（余额），单位：分',
  `recharge_pay_count` int NOT NULL DEFAULT 0 COMMENT '充值订单数',
  `recharge_pay_price` int NOT NULL DEFAULT 0 COMMENT '充值金额，单位：分',
  `recharge_refund_count` int NOT NULL DEFAULT 0 COMMENT '充值退款订单数',
  `recharge_refund_price` int NOT NULL DEFAULT 0 COMMENT '充值退款金额，单位：分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易统计';

-- ----------------------------
-- Table structure for trade_after_sale  [trade]  来源：AfterSaleDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_after_sale`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '售后编号，主键自增',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '售后单号',
  `status` int NOT NULL DEFAULT 0 COMMENT '退款状态',
  `way` int NOT NULL DEFAULT 0 COMMENT '售后方式',
  `type` int NOT NULL DEFAULT 0 COMMENT '售后类型',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `apply_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请原因',
  `apply_description` text NULL COMMENT '补充描述',
  `apply_pic_urls` text NULL COMMENT '补充凭证图片',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '交易订单编号',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单流水号',
  `order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '交易订单项编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品 SPU 名称',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `properties` text NULL COMMENT '属性数组，JSON 格式',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片',
  `count` int NOT NULL DEFAULT 0 COMMENT '退货商品数量',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `audit_user_id` bigint NOT NULL DEFAULT 0 COMMENT '审批人',
  `audit_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批备注',
  `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分。',
  `pay_refund_id` bigint NOT NULL DEFAULT 0 COMMENT '支付退款编号',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `logistics_id` bigint NOT NULL DEFAULT 0 COMMENT '退货物流公司编号',
  `logistics_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退货物流单号',
  `delivery_time` datetime NULL DEFAULT NULL COMMENT '退货时间',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `receive_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货备注',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE,
  KEY `idx_audit_user_id` (`audit_user_id`) USING BTREE,
  KEY `idx_pay_refund_id` (`pay_refund_id`) USING BTREE,
  KEY `idx_logistics_id` (`logistics_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '售后订单，用于处理 {@link TradeOrderDO} 交易订单的退款退货流程';

-- ----------------------------
-- Table structure for trade_after_sale_log  [trade]  来源：AfterSaleLogDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_after_sale_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型',
  `after_sale_id` bigint NOT NULL DEFAULT 0 COMMENT '售后编号',
  `before_status` int NOT NULL DEFAULT 0 COMMENT '操作前状态',
  `after_status` int NOT NULL DEFAULT 0 COMMENT '操作后状态',
  `operate_type` int NOT NULL DEFAULT 0 COMMENT '操作类型',
  `content` text NULL COMMENT '操作明细',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_after_sale_id` (`after_sale_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易售后日志';

-- ----------------------------
-- Table structure for trade_brokerage_record  [trade]  来源：BrokerageRecordDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_brokerage_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务编号',
  `biz_type` int NOT NULL DEFAULT 0 COMMENT '业务类型',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `description` text NULL COMMENT '说明',
  `price` int NOT NULL DEFAULT 0 COMMENT '金额',
  `total_price` int NOT NULL DEFAULT 0 COMMENT '当前总佣金',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `frozen_days` int NOT NULL DEFAULT 0 COMMENT '冻结时间（天）',
  `unfreeze_time` datetime NULL DEFAULT NULL COMMENT '解冻时间',
  `source_user_level` int NOT NULL DEFAULT 0 COMMENT '来源用户等级',
  `source_user_id` bigint NOT NULL DEFAULT 0 COMMENT '来源用户编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_biz_id` (`biz_id`) USING BTREE,
  KEY `idx_source_user_id` (`source_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '佣金记录';

-- ----------------------------
-- Table structure for trade_brokerage_user  [trade]  来源：BrokerageUserDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_brokerage_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户编号',
  `bind_user_id` bigint NOT NULL DEFAULT 0 COMMENT '推广员编号',
  `bind_user_time` datetime NULL DEFAULT NULL COMMENT '推广员绑定时间',
  `brokerage_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否有分销资格',
  `brokerage_time` datetime NULL DEFAULT NULL COMMENT '成为分销员时间',
  `brokerage_price` int NOT NULL DEFAULT 0 COMMENT '可用佣金',
  `frozen_price` int NOT NULL DEFAULT 0 COMMENT '冻结佣金',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_bind_user_id` (`bind_user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分销用户';

-- ----------------------------
-- Table structure for trade_brokerage_withdraw  [trade]  来源：BrokerageWithdrawDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_brokerage_withdraw`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `price` int NOT NULL DEFAULT 0 COMMENT '提现金额，单位：分',
  `fee_price` int NOT NULL DEFAULT 0 COMMENT '提现手续费，单位：分',
  `total_price` int NOT NULL DEFAULT 0 COMMENT '当前总佣金，单位：分',
  `type` int NOT NULL DEFAULT 0 COMMENT '提现类型',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '提现姓名',
  `user_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '提现账号',
  `qr_code_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收款码',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '银行名称',
  `bank_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开户地址',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `audit_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核驳回原因',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `remark` text NULL COMMENT '备注',
  `pay_transfer_id` bigint NOT NULL DEFAULT 0 COMMENT '转账单编号',
  `transfer_channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转账渠道',
  `transfer_time` datetime NULL DEFAULT NULL COMMENT '转账成功时间',
  `transfer_error_msg` text NULL COMMENT '转账错误提示',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_pay_transfer_id` (`pay_transfer_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '佣金提现';

-- ----------------------------
-- Table structure for trade_cart  [trade]  来源：CartDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_cart`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，唯一自增',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `count` int NOT NULL DEFAULT 0 COMMENT '商品购买数量',
  `selected` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否选中',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '购物车的商品信息';

-- ----------------------------
-- Table structure for trade_config  [trade]  来源：TradeConfigDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `after_sale_refund_reasons` text NULL COMMENT '售后的退款理由',
  `after_sale_return_reasons` text NULL COMMENT '售后的退货理由',
  `delivery_express_free_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否启用全场包邮',
  `delivery_express_free_price` int NOT NULL DEFAULT 0 COMMENT '全场包邮的最小金额，单位：分',
  `delivery_pick_up_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否开启自提',
  `brokerage_enabled` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否启用分佣',
  `brokerage_enabled_condition` int NOT NULL DEFAULT 0 COMMENT '分佣模式',
  `brokerage_bind_mode` int NOT NULL DEFAULT 0 COMMENT '分销关系绑定模式',
  `brokerage_poster_urls` text NULL COMMENT '分销海报图地址数组',
  `brokerage_first_percent` int NOT NULL DEFAULT 0 COMMENT '一级返佣比例',
  `brokerage_second_percent` int NOT NULL DEFAULT 0 COMMENT '二级返佣比例',
  `brokerage_withdraw_min_price` int NOT NULL DEFAULT 0 COMMENT '用户提现最低金额',
  `brokerage_withdraw_fee_percent` int NOT NULL DEFAULT 0 COMMENT '用户提现手续费百分比',
  `brokerage_frozen_days` int NOT NULL DEFAULT 0 COMMENT '佣金冻结时间(天)',
  `brokerage_withdraw_types` text NULL COMMENT '提现方式',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易中心配置';

-- ----------------------------
-- Table structure for trade_delivery_express  [trade]  来源：DeliveryExpressDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_delivery_express`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '快递公司 code',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '快递公司名称',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '快递公司 logo',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '快递公司';

-- ----------------------------
-- Table structure for trade_delivery_express_template  [trade]  来源：DeliveryExpressTemplateDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_delivery_express_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模板名称',
  `charge_mode` int NOT NULL DEFAULT 0 COMMENT '配送计费方式',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '快递运费模板';

-- ----------------------------
-- Table structure for trade_delivery_express_template_charge  [trade]  来源：DeliveryExpressTemplateChargeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_delivery_express_template_charge`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '配送模板编号',
  `area_ids` text NULL COMMENT '配送区域编号列表',
  `charge_mode` int NOT NULL DEFAULT 0 COMMENT '配送计费方式',
  `start_count` double NOT NULL DEFAULT 0 COMMENT '首件数量(件数,重量，或体积)',
  `start_price` int NOT NULL DEFAULT 0 COMMENT '起步价，单位：分',
  `extra_count` double NOT NULL DEFAULT 0 COMMENT '续件数量(件, 重量，或体积)',
  `extra_price` int NOT NULL DEFAULT 0 COMMENT '额外价，单位：分',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '快递运费模板计费配置';

-- ----------------------------
-- Table structure for trade_delivery_express_template_free  [trade]  来源：DeliveryExpressTemplateFreeDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_delivery_express_template_free`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `template_id` bigint NOT NULL DEFAULT 0 COMMENT '配送模板编号',
  `area_ids` text NULL COMMENT '配送区域编号列表',
  `free_price` int NOT NULL DEFAULT 0 COMMENT '包邮金额，单位：分',
  `free_count` int NOT NULL DEFAULT 0 COMMENT '包邮件数',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '快递运费模板包邮配置';

-- ----------------------------
-- Table structure for trade_delivery_pick_up_store  [trade]  来源：DeliveryPickUpStoreDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_delivery_pick_up_store`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店简介',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店手机',
  `area_id` int NOT NULL DEFAULT 0 COMMENT '区域编号',
  `detail_address` text NULL COMMENT '门店详细地址',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店 logo',
  `opening_time` time CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '营业开始时间',
  `closing_time` time CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '营业结束时间',
  `latitude` double NOT NULL DEFAULT 0 COMMENT '纬度',
  `longitude` double NOT NULL DEFAULT 0 COMMENT '经度',
  `verify_user_ids` text NULL COMMENT '核销员工用户编号数组',
  `status` int NOT NULL DEFAULT 0 COMMENT '门店状态',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_area_id` (`area_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自提门店';

-- ----------------------------
-- Table structure for trade_order  [trade]  来源：TradeOrderDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单编号，主键自增',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单流水号',
  `type` int NOT NULL DEFAULT 0 COMMENT '订单类型',
  `terminal` int NOT NULL DEFAULT 0 COMMENT '订单来源',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
  `user_remark` text NULL COMMENT '用户备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '订单状态',
  `product_count` int NOT NULL DEFAULT 0 COMMENT '购买的商品数量',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '订单完成时间',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '订单取消时间',
  `cancel_type` int NOT NULL DEFAULT 0 COMMENT '取消类型',
  `remark` text NULL COMMENT '商家备注',
  `comment_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否评价',
  `brokerage_user_id` bigint NOT NULL DEFAULT 0 COMMENT '推广人编号',
  `pay_order_id` bigint NOT NULL DEFAULT 0 COMMENT '支付订单编号',
  `pay_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否已支付',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '付款时间',
  `pay_channel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付渠道',
  `total_price` int NOT NULL DEFAULT 0 COMMENT '商品原价，单位：分',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠金额，单位：分',
  `delivery_price` int NOT NULL DEFAULT 0 COMMENT '运费金额，单位：分',
  `adjust_price` int NOT NULL DEFAULT 0 COMMENT '订单调价，单位：分',
  `pay_price` int NOT NULL DEFAULT 0 COMMENT '应付金额（总），单位：分',
  `delivery_type` int NOT NULL DEFAULT 0 COMMENT '配送方式',
  `logistics_id` bigint NOT NULL DEFAULT 0 COMMENT '发货物流公司编号',
  `logistics_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发货物流单号',
  `delivery_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `receiver_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收件人名称',
  `receiver_mobile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收件人手机',
  `receiver_area_id` int NOT NULL DEFAULT 0 COMMENT '收件人地区编号',
  `receiver_detail_address` text NULL COMMENT '收件人详细地址',
  `pick_up_store_id` bigint NOT NULL DEFAULT 0 COMMENT '自提门店编号',
  `pick_up_verify_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自提核销码',
  `refund_status` int NOT NULL DEFAULT 0 COMMENT '售后状态',
  `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分',
  `coupon_id` bigint NOT NULL DEFAULT 0 COMMENT '优惠劵编号',
  `coupon_price` int NOT NULL DEFAULT 0 COMMENT '优惠劵减免金额，单位：分',
  `use_point` int NOT NULL DEFAULT 0 COMMENT '使用的积分',
  `point_price` int NOT NULL DEFAULT 0 COMMENT '积分抵扣的金额，单位：分',
  `give_point` int NOT NULL DEFAULT 0 COMMENT '赠送的积分',
  `refund_point` int NOT NULL DEFAULT 0 COMMENT '退还的使用的积分',
  `vip_price` int NOT NULL DEFAULT 0 COMMENT 'VIP 减免金额，单位：分',
  `give_coupon_template_counts` text NULL COMMENT '赠送的优惠劵',
  `give_coupon_ids` text NULL COMMENT '赠送的优惠劵编号',
  `seckill_activity_id` bigint NOT NULL DEFAULT 0 COMMENT '秒杀活动编号',
  `bargain_activity_id` bigint NOT NULL DEFAULT 0 COMMENT '砍价活动编号',
  `bargain_record_id` bigint NOT NULL DEFAULT 0 COMMENT '砍价记录编号',
  `combination_activity_id` bigint NOT NULL DEFAULT 0 COMMENT '拼团活动编号',
  `combination_head_id` bigint NOT NULL DEFAULT 0 COMMENT '拼团团长编号',
  `combination_record_id` bigint NOT NULL DEFAULT 0 COMMENT '拼团记录编号',
  `point_activity_id` bigint NOT NULL DEFAULT 0 COMMENT '积分商城活动的编号',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_brokerage_user_id` (`brokerage_user_id`) USING BTREE,
  KEY `idx_pay_order_id` (`pay_order_id`) USING BTREE,
  KEY `idx_logistics_id` (`logistics_id`) USING BTREE,
  KEY `idx_receiver_area_id` (`receiver_area_id`) USING BTREE,
  KEY `idx_pick_up_store_id` (`pick_up_store_id`) USING BTREE,
  KEY `idx_coupon_id` (`coupon_id`) USING BTREE,
  KEY `idx_seckill_activity_id` (`seckill_activity_id`) USING BTREE,
  KEY `idx_bargain_activity_id` (`bargain_activity_id`) USING BTREE,
  KEY `idx_bargain_record_id` (`bargain_record_id`) USING BTREE,
  KEY `idx_combination_activity_id` (`combination_activity_id`) USING BTREE,
  KEY `idx_combination_head_id` (`combination_head_id`) USING BTREE,
  KEY `idx_combination_record_id` (`combination_record_id`) USING BTREE,
  KEY `idx_point_activity_id` (`point_activity_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易订单';

-- ----------------------------
-- Table structure for trade_order_item  [trade]  来源：TradeOrderItemDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单编号',
  `cart_id` bigint NOT NULL DEFAULT 0 COMMENT '购物车项编号',
  `spu_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SPU 编号',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品 SPU 名称',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品 SKU 编号',
  `properties` text NULL COMMENT '属性数组，JSON 格式',
  `pic_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片',
  `count` int NOT NULL DEFAULT 0 COMMENT '购买数量',
  `comment_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否评价',
  `price` int NOT NULL DEFAULT 0 COMMENT '商品原价（单），单位：分',
  `discount_price` int NOT NULL DEFAULT 0 COMMENT '优惠金额（总），单位：分',
  `delivery_price` int NOT NULL DEFAULT 0 COMMENT '运费金额（总），单位：分',
  `adjust_price` int NOT NULL DEFAULT 0 COMMENT '订单调价（总），单位：分',
  `pay_price` int NOT NULL DEFAULT 0 COMMENT '应付金额（总），单位：分',
  `coupon_price` int NOT NULL DEFAULT 0 COMMENT '优惠劵减免金额，单位：分',
  `point_price` int NOT NULL DEFAULT 0 COMMENT '积分抵扣的金额，单位：分',
  `use_point` int NOT NULL DEFAULT 0 COMMENT '使用的积分',
  `give_point` int NOT NULL DEFAULT 0 COMMENT '赠送的积分',
  `vip_price` int NOT NULL DEFAULT 0 COMMENT 'VIP 减免金额，单位：分',
  `after_sale_id` bigint NOT NULL DEFAULT 0 COMMENT '售后单编号',
  `after_sale_status` int NOT NULL DEFAULT 0 COMMENT '售后状态',
  `property_id` bigint NOT NULL DEFAULT 0 COMMENT '属性编号',
  `property_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性名字',
  `value_id` bigint NOT NULL DEFAULT 0 COMMENT '属性值编号',
  `value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性值名字',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_cart_id` (`cart_id`) USING BTREE,
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE,
  KEY `idx_after_sale_id` (`after_sale_id`) USING BTREE,
  KEY `idx_property_id` (`property_id`) USING BTREE,
  KEY `idx_value_id` (`value_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易订单项';

-- ----------------------------
-- Table structure for trade_order_log  [trade]  来源：TradeOrderLogDO.java
-- ----------------------------
CREATE TABLE IF NOT EXISTS `trade_order_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` int NOT NULL DEFAULT 0 COMMENT '用户类型',
  `order_id` bigint NOT NULL DEFAULT 0 COMMENT '订单号',
  `before_status` int NOT NULL DEFAULT 0 COMMENT '操作前状态',
  `after_status` int NOT NULL DEFAULT 0 COMMENT '操作后状态',
  `operate_type` int NOT NULL DEFAULT 0 COMMENT '操作类型',
  `content` text NULL COMMENT '订单日志信息',
  `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单日志';

