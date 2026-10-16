-- ============================================================================
--  【执行顺序 ⑤ / 共 6 步 · 可选】积木报表 2.5.1 补充建表 —— 4 张表
--  前置：同目录 jimureport-ddl-only.sql 已执行
--  可重复执行：是（CREATE TABLE IF NOT EXISTS）
-- ============================================================================
-- JimuReport 2.5.1 —— 补充建表脚本（4 张较新版本新增的表）
--
-- 为什么需要这个文件：
--   上游仓库历史版本里的 jimureport.mysql5.7.create.sql 只有 16 张表，
--   而本项目实际使用的 jimureport-spring-boot4-starter **2.5.1** 还会访问以下 4 张表：
--       jimu_report_category      报表分类
--       jimu_report_export_job    导出任务
--       jimu_report_export_log    导出日志
--       jimu_report_ext_data      扩展数据
--   缺少它们时，使用报表分类 / 导出功能会报 "Table doesn't exist"。
--
-- 本文件如何得到（可复核）：
--   · **列名是精确的**：直接取自 jimureport-spring-boot4-starter-2.5.1.jar 内
--     各 DAO 的 insert 语句（JimuReportCategoryDao_insert.sql 等），
--     即该版本代码真正会写入的字段，逐字对应。
--   · **列类型是按 JimuReport 自身惯例推断的**：同一脚本中既有表的写法为
--     id varchar(36)、create_by varchar(50)、create_time datetime、
--     长内容用 longtext/text、tenant_id varchar(10)、标记位用 varchar(10) 等。
--     列类型均为宽松类型（varchar/text/datetime/int），MySQL 会做隐式转换，
--     因此不会因类型推断造成写入失败。
--
-- ⚠️ 若日后 JimuReport 升级，请以其官方对应版本的建表脚本为准替换本文件。
-- ============================================================================

SET NAMES utf8mb4;

-- ----------------------------
-- 报表分类
-- ----------------------------
CREATE TABLE IF NOT EXISTS `jimu_report_category`  (
  `id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分类名称',
  `parent_id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '父级ID',
  `iz_leaf` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否叶子节点',
  `source_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '来源类型(report:报表;drag:仪表盘)',
  `create_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人登录名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新人登录名称',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `del_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '0表示未删除,1表示删除',
  `tenant_id` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多租户标识',
  `sort_no` int NULL DEFAULT NULL COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_jimu_report_category_parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic COMMENT = '报表分类';

-- ----------------------------
-- 导出任务
-- ----------------------------
CREATE TABLE IF NOT EXISTS `jimu_report_export_job`  (
  `id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务名称',
  `begin_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `exec_interval` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行间隔',
  `report_conf` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '报表配置',
  `last_run_time` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `receiver_email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '接收邮箱',
  `file_sync_path` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '文件同步路径',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态',
  `create_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人登录名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新人登录名称',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  `tenant_id` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多租户标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic COMMENT = '导出任务';

-- ----------------------------
-- 导出日志
-- ----------------------------
CREATE TABLE IF NOT EXISTS `jimu_report_export_log`  (
  `id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `batch_no` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '批次号',
  `export_channel` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '导出渠道',
  `export_from` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '导出来源',
  `from_id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '来源ID',
  `export_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '导出类型',
  `report_id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '报表ID',
  `download_path` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '下载路径',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态',
  `err_msg` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '错误信息',
  `create_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人登录名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `tenant_id` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多租户标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_jimu_report_export_log_report_id`(`report_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic COMMENT = '导出日志';

-- ----------------------------
-- 扩展数据
-- ----------------------------
CREATE TABLE IF NOT EXISTS `jimu_report_ext_data`  (
  `id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `biz_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '业务类型',
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
  `descr` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
  `tags` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标签',
  `data_value` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '数据值',
  `metadata` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '元数据',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态',
  `create_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人登录名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新人登录名称',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic COMMENT = '扩展数据';
