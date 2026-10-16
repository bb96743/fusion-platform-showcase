# report 模块改造计划

| | |
|---|---|
| **归属会话** | report 模块改造 |
| **当前状态** | ⏸ **待 D4 决策**（本期是否使用报表） |
| **上游基线** | 后端 `master-jdk25 @ 21f5e82e51` |
| **最后更新** | 2026-10-04 |

---

## 1. 立项

- **业务目标**：报表与数据大屏（积木报表 JimuReport + GoView 大屏）
- **保留范围**：积木报表（报表设计、数据源、打印）、GoView 数据大屏
- **明确不做**：上游的报表演示模板与示例数据集
- **验收标准**：14.4 清单全过 + 冒烟全绿 + 能设计并打开一张自有报表

## 2. 现状实测

| 项 | 实测值 | 备注 |
|---|---|---|
| 积木报表表 | **20 张**（`jimu*` / `rep_demo*` / `tmp_report*`） | 由 `optional/jimureport-ddl-only.sql`(16) + `jimureport-supplement-2.5.1.sql`(4) 建 |
| JimuReport 版本 | **2.5.1** | 上游最新 **2.5.4** |
| 冒烟接口 | `report/go-view/project/my-page` → `code=0` | 模块已启用 |
| GoView 前端地址 | `VITE_APP_GOVIEW_URL` 在 `.env.prod` / `.env.stage` / `.env.test` 已置空 | 本机联调时才需要填 |
| 建库开关 | 未加 `-WithJimuReport` 时**不建**这 20 张表 | `init-db.ps1 -Apply -WithJimuReport` |

## 3. 待决策（D4）与后续分支

| 决策 | 后续动作 |
|---|---|
| **本期不用** | **隐藏菜单**（`system_menu.visible=b'0'`）；积木报表的 20 张表可保留（占用可忽略） |
| **本期要用** | ① 升级 JimuReport ② 配数据源、设计自有报表 ③ 决定 GoView 是否保留（另需独立部署 GoView 前端） |

## 4. 上游可摘（升级时一起做）

| 优先级 | 提交 | 内容 |
|---|---|---|
| ★★★ | 后端 `96d3e5cd8c` / `5b2a335a1c` | **升级 BOM 依赖并保持各 Spring Boot 版本的积木报表兼容性**（`jimureport 2.5.1 → 2.5.4`） |
| ★★★ | 后端 `4f3126771e` | **排除积木报表传递引入的旧版 Swagger Jakarta 注解依赖**（否则可能与新版本 Spring Boot 冲突） |
| ★★★ | 后端 `53af673d04` / `b0fc5856fb` | 启用 AI 与报表模块并按项目版本对齐 Spring AI BOM（**注意：其中 AI 部分我们已用 14.16 的方案解决，摘取时只取报表相关**） |

> ⚠️ 升级 JimuReport 属于**依赖版本变更**，改完必须重跑 `verify-all.ps1`，并手工打开一次报表设计器。

## 5. 需要注意

1. **`optional/jimureport-*.sql` 是 `DROP TABLE` + `CREATE TABLE`** —— 重跑会**清空**积木报表数据。
2. 积木报表的入口在后端 `/jmreport/*`，多租户忽略清单里有它（`fusion.tenant.ignore-urls`），
   我们现在已关闭多租户，这条配置可留可删。
3. 报表表**不在**基线重建的清理范围内（`fusion-init.sql` 只 DROP `system_*` / `infra_*` / QRTZ），
   所以重建库不会影响已设计的报表 —— 但也意味着**报表数据不会随基线重置**，需要人工清理演示模板。
