# Fusion

一个基于 Spring Boot 4 + Vue 3 的后台管理系统。

> 本项目的代码基座来自若干开源项目（MIT 许可）的二次开发，原始版权声明见
> [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)。上游仓库链接与作者推广内容已移除。

---

## 技术栈

| 层次 | 选型 | 版本 |
|---|---|---|
| JDK | Java | **21**（最低要求 17） |
| 框架 | Spring Boot | **4.1.1** |
| | Spring Framework / Security | 7.0.x / 7.1.x |
| | Jackson | 3.x |
| 数据 | MySQL | 8.x |
| | MyBatis-Plus | 3.5.17（`mybatis-plus-spring-boot4-starter`） |
| | Druid / dynamic-datasource | 1.2.28 / 4.5.0 |
| | Redis / Redisson | 4.7.0（`redisson-spring-data-41`） |
| 工作流 | Flowable | 8.0.0 |
| 报表 | 积木报表 + GoView | — |
| AI | Spring AI | **2.0.x** |
| 接口文档 | springdoc-openapi | 3.0.x |
| 构建 | Maven | 3.6.3+ |
| 前端 | Vue 3 + Vite + Element Plus + TypeScript | 见 `fusion-ui-admin/package.json` |

---

## 模块结构

```
fusion
├── fusion-dependencies                            依赖版本统一管理（BOM）
├── fusion-framework                               框架扩展层
│   ├── fusion-common                              通用工具
│   └── fusion-spring-boot-starter-{web,security,mybatis,redis,job,mq,
│       monitor,excel,test,websocket,biz-tenant,biz-data-permission,biz-ip}
├── fusion-server                                  启动模块
├── fusion-module-system                           系统功能（用户/角色/菜单/部门/字典/租户/…）
├── fusion-module-infra                            基础设施（代码生成/文件/配置/定时任务/日志）
├── fusion-module-bpm                              工作流
├── fusion-module-report                           报表大屏
└── fusion-module-ai                               AI 能力
```

---

## 快速开始

### 0. 一键拉起（推荐）

仓库里已经备好脚本，**新克隆的环境按这三步走**（在 `_runtime\` 目录下执行）：

```powershell
cd _runtime

.\check-env.ps1 -Fix      # 1. 自检环境；-Fix 会从模板复制缺失的本地配置、并设好 git 钩子
.\init-db.ps1 -Apply      # 2. 一键建库：基线 SQL + 迁移 + 自动生成管理员口令
.\build-all.ps1           # 3. 构建后端 + 前端（首次会下载依赖，稍慢）
.\start-dev.ps1 -All      # 4. 起 Redis + 后端 + 前端
.\stop-dev.ps1            # 停止
```

> `init-db.ps1` 会自动从 `application-local.yaml` 读取数据库口令，所以第 1 步之后
> 先确认那个文件里的口令是对的。加 `-WithJimuReport` 可一并建积木报表的 20 张表；
> 加 `-Reset`（危险）会先 `DROP DATABASE`。
>
> `init-db.ps1` 会在末尾自动执行数据库迁移，并**生成一个管理员强口令**写入
> `fusion-ui-admin/.env.env.local`（该文件不入库）—— 种子 SQL 里的口令是占位符，
> 所以全新环境必须由这一步设置口令，否则谁都登录不进去。
>
> 各脚本的详细说明见脚本头部注释，以及 `../需求分析文档.md` 的「运行与协作约定」（14.10）。

下面的 1~3 节是**手工等价操作**，用于理解每一步在做什么，或脚本不适用时使用。

### 1. 准备数据库（手工方式）

**必须按下面的顺序执行 4~5 个脚本**，缺任何一个都会导致启动失败或页面空白
（BPM / AI / 报表 / 定时任务的表分别在不同文件里）：

```bash
# ① 建库（库名默认 fusion，如改库名，同步改 application-local.yaml 的 url）
mysql -u root -p -e "CREATE DATABASE fusion DEFAULT CHARACTER SET utf8mb4;"

# ② 系统与基础设施表结构 + 种子数据（菜单 / 字典 / 角色 / 管理员）
mysql -u root -p fusion < sql/mysql/fusion-init.sql

# ③ 工作流(bpm) / AI / 报表(report) 共 23 张表
mysql -u root -p fusion < sql/mysql/fusion-modules.sql

# ④ 定时任务（Quartz）11 张表
mysql -u root -p fusion < sql/mysql/quartz.sql

# ⑤ 仅当使用「报表管理 → 积木报表」时需要：20 张表
mysql -u root -p fusion < sql/mysql/optional/jimureport-ddl-only.sql
mysql -u root -p fusion < sql/mysql/optional/jimureport-supplement-2.5.1.sql
```

> ⚠️ **④ 必须在 ② 之后执行**：`quartz.sql` 末尾的清理段要依据 `fusion-init.sql`
> 已经清理过的 `infra_job` 来判断哪些调度项是孤儿（见 `../需求分析文档.md` 13.16.7）。
>
> ⚠️ **② 与 ④ 会重建各自的表**：`fusion-init.sql` 会清空 `system_*` / `infra_*` 的
> 运行期数据（上传的文件、日志、手工改过的菜单），只保留脚本里的种子数据。
> 只想改少量数据时请写编号迁移脚本，不要重跑这两个文件。
>
> ⚠️ 所有 `.sql` 文件都**不能带 BOM**（BOM 会让 mysql 客户端把首句当成非法字符）。
>
> 验证是否建对：库表总数应为 **142**（未建积木报表时 122），`system_menu` 应为 **297** 行，
> `system_users` 应只剩 **1** 个账号（admin）。

Flowable 引擎自身的 `ACT_*` / `FLW_*` 表（45 张）**不需要手工建** ——
首次启动时由 `flowable.database-schema-update=true` 自动创建。

> ⚠️ **口令已重设（F0）。** 交付时 `sql/mysql/fusion-init.sql` 里 21 个账号共用的是
> **上游默认弱口令 `123456`**，现已替换为随机强口令，并删除了 20 个上游演示账号
> （库中只剩 `admin` 一个账号）。
>
> 本地开发口令见 `fusion-ui-admin/.env.env.local` 的 `VITE_APP_DEFAULT_LOGIN_PASSWORD`
> （该文件只在 `pnpm dev` 时加载，不会进入生产包）。
>
> 若你要为**非本机环境**重设口令：
>
> ```powershell
> cd ..\_tooling
> .\14-set-admin-password.ps1 -Apply -UpdateDatabase    # 不加 -Password 则生成随机强口令
> ```
>
> 该脚本会同时改写 `fusion-init.sql` 与当前数据库。
> （相关背景见 `需求分析文档.md` 13.15 C1 与第 14 章 F0。）

> ⚠️ **不要执行 `sql/mysql/ai-deepseek-seed.sql`。** 它是未落地的草稿，且内含
> **明文真实 API Key**，其 `ai_chat_role` 的 `id=1` 与库中的「写作助手」冲突 ——
> AI 写作 / 思维导图是按角色名精确匹配的，执行会让这两个功能失效。
> AI 的密钥与模型请在「AI 大模型 → API 密钥 / 模型管理」页面里配置。
> （见 `需求分析文档.md` 13.15 C5、C6。）

### 2. 启动后端（手工方式）

先准备本机配置 —— `application-local.yaml` **不入版本库**（它含本机数据库口令），
首次需要从模板复制：

```powershell
copy fusion\fusion-server\src\main\resources\application-local.yaml.example `
     fusion\fusion-server\src\main\resources\application-local.yaml
# 然后编辑它，把 master / slave 数据源的 password 改成你的 MySQL 口令
```

**后端依赖 Redis**（Redisson 缓存 / 验证码 / MQ）。本机没有 Redis 时，
仓库自带一份本地开发用的 `redis-server`（Windows 版），并用一键脚本拉起：

```powershell
cd ..\_runtime
.\start-dev.ps1              # 启动 Redis + 后端（后台运行，日志见 _runtime\logs）
.\start-dev.ps1 -All         # 再加上前端
.\start-dev.ps1 -RedisOnly   # 只起 Redis
.\stop-dev.ps1               # 停止（按 PID 精确停止，不会误杀其它 java/node）
```

手工构建与启动：

```bash
mvn -f pom.xml clean package -DskipTests
java -jar fusion-server/target/fusion-server.jar
```

配置从 `fusion-server/src/main/resources/application-local.yaml` 读取
（`spring.profiles.active: local`），数据源、Redis 地址都在这里改。
另有 `application-dev.yaml`（独立开发服务器）与 `application-prod.yaml`（生产模板）。

默认端口 `48080`，接口文档 `http://localhost:48080/doc.html`。

### 3. 启动前端（手工方式）

先准备 `.env.env.local` —— 它**不入版本库**（含管理员口令），首次需要从模板复制：

```powershell
copy fusion-ui-admin\.env.env.local.example fusion-ui-admin\.env.env.local
# 然后填入 VITE_APP_DEFAULT_LOGIN_PASSWORD（数据库里 admin 的口令）
```

```bash
cd fusion-ui-admin
pnpm install
pnpm dev            # 本地开发（vite --mode env.local）
pnpm build:prod     # 生产构建（输出 dist-prod）
```

前端请求地址由 `.env.*` 中的 `VITE_BASE_URL` 控制（空值 = 同源，配合 nginx 反向代理）。
各 `.env` 文件的加载范围见 `fusion-ui-admin/README.md` 的「环境变量」一节 ——
注意 **`.env.local` 在所有模式下都会加载**，本地专用的账号密码必须写在 `.env.env.local`。

---

## 品牌资源

Logo 与图标由脚本生成，可随时替换：

- 矢量源：`_branding/fusion-logo.svg`（改配色/形状最方便）
- 重新生成：`_tooling/08-generate-branding.ps1 -Primary '#4F46E5' -Secondary '#06B6D4'`
- 装入工程：追加 `-AlsoInstall`

涉及的文件：`public/favicon.ico`、`public/logo.gif`、`src/assets/imgs/logo.png`、
`src/assets/imgs/avatar.{png,gif}`、`fusion-framework/.../resources/banner.txt`。

---

## 配置前缀

本项目自有配置统一使用 `fusion.` 前缀（例如 `fusion.info.base-package`、`fusion.ai.*`、
`fusion.tenant.enable`）。注意与 Spring AI 官方的 `spring.ai.*` 区分 —— 二者互不影响。

---

## 数据库变更（迁移）

**基线**（`fusion-init.sql` / `fusion-modules.sql` / `quartz.sql` + 可选积木报表）
由 `_runtime\init-db.ps1` 负责；**基线之后的增量变更走迁移机制**：

```
fusion\sql\mysql\migrations\V<序号>__<描述>.sql     例：V002__add-order-remark.sql
```

```powershell
cd ..\_runtime
.\db-migrate.ps1            # 看状态：哪些已执行 / 待执行
.\db-migrate.ps1 -Apply     # 执行所有未执行的迁移
.\db-migrate.ps1 -Baseline  # 把现有迁移登记为「已执行」但不执行（接管既有库用）
```

约定（详见 `../需求分析文档.md` 14.6 / 14.11）：

- **只增不改** —— 已经执行过的迁移文件**不得再改内容**。脚本用 SHA-256 校验，
  改过会被判为错误并中止（防止各环境结构悄悄分叉）。要改就新加一个更大的序号。
- 迁移记录存在库里的 `schema_migration` 表（由脚本自动创建）。
- 写迁移时注意：**多租户**——查询会被自动加上 `tenant_id = 当前租户`；
  种子数据若把 `tenant_id` 写成 0，会出现「库里有、接口查不到」（`V001` 踩过）。

---

## 容器部署

仓库根目录提供了 `docker-compose.yml`（MySQL + Redis + 后端 + 前端）：

```bash
copy .env.example .env      # 改掉 MYSQL_ROOT_PASSWORD 等
docker compose up -d mysql redis
docker compose up -d --build server admin
# 前端 http://127.0.0.1:8080    后端 http://127.0.0.1:48080/actuator/health
```

- 后端镜像 `fusion/fusion-server/Dockerfile`（多阶段：Maven 构建 → JRE 运行，非 root）
- 前端镜像 `fusion-ui-admin/Dockerfile` + `fusion-ui-admin/nginx.conf`
  （SPA 回退、`/admin-api` 反向代理、SSE 关缓冲）
- 前端构建读的是仓库里已提交的 `.env.prod`，所以镜像与本地构建用的是**同一套配置**

> ⚠️ **容器方案尚未在真实 Docker 上验证过**（开发机未安装 Docker），文件头已标注。
> ⚠️ MySQL 只在**数据卷为空**时执行初始化 SQL；改完 SQL 需要 `docker compose down -v`
> （会删数据）才会重新执行。容器库的管理员口令同样是占位符，首次启动后要单独设置。

---
## 后续改造

本项目目前处于**第二阶段：自有品牌业务化**（第一阶段「把上游改造成自有品牌」已完成）。

计划、模块改造顺序、单模块标准流程（SOP）与进度看板都写在
`../需求分析文档.md` 的**第 14 章**：

| 需要什么 | 看哪节 |
|---|---|
| 现在站在哪、目标与验收标准 | 14.1 / 14.2 |
| 阶段划分（F0 收口 → F5 上线） | 14.3 |
| **每做一个模块该走哪 7 步 + 检查清单** | **14.4** |
| 模块改造顺序与理由 | 14.5 |
| 数据库变更管理约定 | 14.6 |
| 当前进度看板 | 14.7 |
| 风险与待决策项 | 14.8 |

改造工具链在 `../_tooling/`，用法见 `../_tooling/README.md`。

---

## 许可

MIT。原始版权声明见 [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)。
