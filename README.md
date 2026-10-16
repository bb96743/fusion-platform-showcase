# Fusion 数智业务中台

一套基于 **Spring Boot 4 + Vue 3** 的企业级后台管理系统基座，**32 个 Maven 模块**（14 个一级模块，商城再下分 5 个子模块）、**11 个业务模块**，约 **48 万行源码**（Java 29.8 万行 / Vue 18.7 万行）。

> 本仓库是**改造工程成果的展示副本**：用于呈现架构设计、模块划分与工程化改造过程。
> 出于公开与安全考虑，**本仓库不含任何真实凭据、内部过程产物与运行环境**，也**不承诺开箱即跑通** —— 详细边界见文末「本仓库的定位与边界」。

---

## 一、这是什么

Fusion 由一套开源后台脚手架（芋道 ruoyi-vue-pro / yudao-ui-admin-vue3，MIT 许可）**深度二次开发**而来。改造的目标不是"跑起来一个 demo"，而是把它变成一个**自有品牌、可独立编译、可独立部署、可持续演进**的项目基座：

| # | 改造方向 | 关键工作 |
|---|---|---|
| 1 | **品牌与标识替换** | 全仓库范围内清除上游名称/图标/作者标识/推广痕迹，替换为 Fusion 自有品牌（前端标题、后端 banner、Swagger、库名、配置前缀一并收敛到 `fusion.*`） |
| 2 | **框架层大版本升级** | Spring Boot 2.7 → **4.1.1**，JDK 8 → **21**，跨两个大版本；逐项解决破坏性变更（Jackson 2→3、Spring Security 6→7、MyBatis-Plus / Druid / Redisson 的 Boot 4 starter 迁移） |
| 3 | **Spring AI 2.0 接入** | AI 模块从 spring-ai 1.x 升级到 **2.0.1**，处理 API 破坏性变更（`ChatMemory` 包路径迁移、`FunctionCallback` → `ToolCallback`、MCP 服务端接入） |
| 4 | **模块化裁剪与整合** | 识别并移除与业务无关的上游演示模块（IoT / CMS / 工作流演示等），从上游基线**逐个移植**所需业务模块并补齐依赖闭包 |
| 5 | **工程质量体系** | 建立数据库迁移机制、环境自检、构建/冒烟验证、上游同步与摘取方法论等工程化手段 |
| 6 | **数据库瘦身与重建** | 清理上游演示数据（68 张截图、演示账号、孤儿菜单/定时任务），重建为干净的种子数据 |

---

## 二、技术栈

### 后端

| 类别 | 组件 | 版本 |
|---|---|---|
| 语言/运行时 | Java | **21**（源码 `maven.compiler.source/target=21`） |
| 框架 | **Spring Boot** | **4.1.1** |
| | Spring Framework | 7.0.x |
| | Spring Security | 7.1.x |
| | Jackson | 3.x |
| 数据库 | MySQL | 8.x |
| ORM | **MyBatis-Plus** | **3.5.17**（`mybatis-plus-spring-boot4-starter`） |
| | MyBatis | 3.5.19 |
| | MyBatis-Plus-Join | 1.5.9 |
| 连接池 | Druid | 1.2.28（`druid-spring-boot-4-starter`） |
| | dynamic-datasource | 4.5.0 |
| 缓存 | **Redisson** | **4.7.0**（配 `redisson-spring-data-41`） |
| 工作流 | Flowable | 7.x |
| 定时任务 | Quartz（集群模式） | 2.x |
| AI | **Spring AI** | **2.0.1** |
| 监控 | Spring Boot Admin | 4.1.2 |

### 前端

| 类别 | 组件 | 版本 |
|---|---|---|
| 框架 | **Vue** | **3.5.34** |
| 构建 | **Vite** | **8.1.4** |
| 语言 | TypeScript | 6.0.3 |
| UI | Element Plus | 2.13.7 |
| 状态 | Pinia | 3.0.4 |
| 路由 | Vue Router | 5.0.6 |
| 国际化 | Vue i18n | 11.4.0 |
| 图表 | ECharts | 6.0.0 |
| HTTP | Axios | 1.16.0 |
| 运行时 | Node.js | ≥ 20.19.0 |

---

## 三、模块划分

### 后端（14 个一级 Maven 模块，共 32 个）

```
fusion-dependencies      依赖版本统一管理（BOM）
fusion-framework         框架层：13 个 starter（web / security / mybatis / redis / mq / job / monitor / excel / websocket / 租户 / 数据权限 / IP / test）+ common 工具集
fusion-server            启动模块（聚合所有业务模块）
├── fusion-module-system   系统管理   用户 / 组织 / 角色 / 权限 / 菜单 / 字典 / 日志 / OAuth2 / 短信 / 邮件 / 社交登录
├── fusion-module-infra    基础设施   代码生成 / 文件存储 / 配置中心 / 定时任务 / 访问日志 / API 日志
├── fusion-module-bpm      工作流     Flowable 引擎 / 流程设计器 / 任务审批 / 动态表单（8 张表 + Flowable 引擎表）
├── fusion-module-report   报表大屏   积木报表（JimuReport）+ GoView 数据大屏（1 张表 + 可选 20 张）
├── fusion-module-ai       AI 能力    对话 / 写作 / 思维导图 / 知识库 / 文生图 / 模型与密钥管理 / MCP（14 张表）
├── fusion-module-mall     商城系统   商品 / 营销 / 交易 / 统计（下分 5 个子模块，49 张表）
├── fusion-module-member   会员中心   会员 / 等级 / 积分 / 签到（11 张表）
├── fusion-module-pay      支付管理   支付 / 退款 / 转账 / 钱包 / 回调（14 张表）
├── fusion-module-erp      ERP 系统   采购 / 销售 / 库存 / 财务（33 张表）
├── fusion-module-crm      CRM 系统   客户 / 商机 / 合同 / 回款（21 张表）
└── fusion-module-mes      MES 系统   制造执行：基础数据 / 计划 / 生产 / 质量 / 库存（133 张表）
```

### 前端（`fusion-ui-admin/`，Vue 3 + Element Plus）

按模块组织视图与 API，与后端模块一一对应：

| 模块 | 视图数 | 模块 | 视图数 |
|---|---:|---|---:|
| `mes` 制造执行 | 284 | `mall` 商城 | 124 |
| `crm` 客户关系 | 118 | `ai` 大模型 | 69 |
| `system` 系统管理 | 68 | `erp` 企业资源 | 63 |
| `bpm` 工作流 | 45 | `member` 会员 | 32 |
| `infra` 基础设施 | 26 | `pay` 支付 | 23 |
| `report` 报表 | 3 | 登录/个人中心/错误页等 | 21 |

---

## 四、架构要点

### 分层与依赖

后端采用 **依赖管理（BOM）+ 框架层 starter 化 + 业务模块自治** 的三层结构：

- `fusion-dependencies`：集中锁定所有三方依赖版本，业务模块不写版本号；
- `fusion-framework`：把横切能力做成 13 个可插拔 starter（另含 `fusion-common` 工具集），业务模块按需引入；
- `fusion-module-*`：每个模块自持 `controller / service / dal / convert / enums / framework` 分层，模块间只通过 `api` 包（DTO + 接口）通信，不直接依赖彼此的 DAL。

### 关键机制

| 机制 | 说明 |
|---|---|
| **多租户** | 基于 MyBatis-Plus 拦截器 + 动态数据源实现，租户隔离在 SQL 层自动注入；**已决策关闭逻辑但保留代码与开关**，便于日后启用 |
| **数据权限** | 声明式数据范围（全部/本级/本部门/本部门及以下/仅本人），通过 AOP + SQL 改写实现 |
| **数据库迁移** | 编号迁移脚本（`V001__` … `V018__`）+ `schema_migration` 表自举，增量变更不重跑基线 SQL |
| **权限模型** | 菜单/按钮级 `permission` 标识 + 角色绑定 + 前端指令式鉴权（`v-hasPermi`） |
| **接口文档** | Knife4j / OpenAPI 3，Spring Boot 4 下完成适配 |
| **参数加密** | 支持 AES / RSA 的请求响应加密（`fusion.api-encrypt.*`） |
| **数据脱敏** | 手机号 / 身份证 / 银行卡 / 车牌等滑块式脱敏注解 |
| **异常与日志** | 全局异常处理 + 业务异常码体系 + 操作日志/登录日志（含定时清理任务） |

### 数据库

- 基线建表 SQL 按**顺序敏感**的 5 个文件组织（系统与基础设施 → 业务模块 → Quartz → 可选报表）；
- 业务模块表结构与种子数据集中在 `fusion/sql/mysql/`；
- 增量变更一律走 `migrations/` 下的编号脚本。

---

## 五、目录结构

```
.
├── fusion/                          后端（Spring Boot 4 / Maven 多模块，共 32 个模块）
│   ├── fusion-dependencies/         依赖 BOM
│   ├── fusion-framework/            13 个框架 starter + common 工具集
│   ├── fusion-server/               启动模块 + 配置
│   ├── fusion-module-*/             11 个业务模块
│   └── sql/mysql/                   建表 SQL + 迁移脚本
├── fusion-ui-admin/                 前端（Vue 3 + Vite + Element Plus）
│   ├── src/api/                     按模块组织的接口层
│   ├── src/views/                   按模块组织的页面
│   ├── src/components/              通用组件（含 BPMN 设计器、验证码、上传…）
│   └── src/utils/                   工具层（鉴权 / 加解密 / 字典 / 请求封装…）
├── docs/
│   ├── README.md                    文档地图与协作规则
│   └── plans/                       各模块改造计划（范围 / 决策 / 验收记录）
├── 需求分析文档.md                   总体改造方案（现状分析 / 升级可行性 / 裁剪方案 / 风险登记）
├── docker-compose.yml               本地依赖编排（MySQL / Redis 等）
└── .github/workflows/ci.yml         构建 + 冒烟 CI
```

---

## 六、本地运行（需自行准备环境）

> ⚠️ 本仓库为展示副本，**未附带运行期产物与本地配置**。以下步骤描述原始项目的运行方式，**不保证在本副本上直接可用**。

**前置**：JDK 21、Maven 3.9+、Node ≥ 20.19、pnpm、MySQL 8、Redis。

```bash
# 1) 建库（顺序敏感）
mysql -u root -p -e "CREATE DATABASE fusion DEFAULT CHARACTER SET utf8mb4;"
mysql -u root -p fusion < fusion/sql/mysql/fusion-init.sql      # 系统与基础设施
mysql -u root -p fusion < fusion/sql/mysql/fusion-modules.sql   # 业务模块表
mysql -u root -p fusion < fusion/sql/mysql/quartz.sql           # 定时任务

# 2) 本地配置：复制模板后填入自己的数据库口令
cp fusion/fusion-server/src/main/resources/application-local.yaml.example \
   fusion/fusion-server/src/main/resources/application-local.yaml

# 3) 后端
mvn -f fusion/pom.xml clean package
java -jar fusion/fusion-server/target/fusion-server.jar --spring.profiles.active=local

# 4) 前端
cd fusion-ui-admin && pnpm install && pnpm dev
```

种子 SQL 中的口令与密钥字段均为**占位符**（`REPLACE_WITH_*`），需自行生成 bcrypt 口令并写入，
或在管理后台「AI 大模型 → API 密钥」中配置模型密钥。

---

## 七、改造工程方法论（本项目最有价值的部分）

这次改造沉淀了一套可复用的工程方法，而非一次性的结果：

1. **现状分析先行** —— 在动代码前，先产出后端/前端/数据库/品牌标识四份清单与升级可行性报告，把"改什么、为什么、风险在哪"写清楚再动手。
2. **依赖闭包 + 分批移植** —— 从上游移植业务模块时，先算清 Maven 依赖闭包与菜单/权限/字典的关联面，按批次移植并逐批验证，避免"改一半编译不过"。
3. **迁移脚本化** —— 所有数据库变更（改名、裁剪菜单、清理演示数据、关闭开放注册）都落成编号迁移，可重复执行、可追溯。
4. **每步可验证** —— 每个小步骤完成后立即提交，并跑编译/冒烟验证；连续提交而非积压成大提交，保证中断后仍可定位与回滚。
5. **品牌一致性检查** —— 建立扫描规则，防止上游名称/作者标识在后续合入时"回流"。

---

## 八、本仓库的定位与边界

### 为什么单独建一个展示仓库

原开发仓库为**私有仓库**，且其 Git 历史中包含早期误提交的本地配置与示例凭据。GitHub 的可见性是**按仓库**而非按分支控制的 —— 一旦转为公开，**所有分支与全部历史提交**都会一并公开。因此这里采用**全新单提交历史**的独立展示仓库，从源头不留敏感历史；原私有仓库与开发流程完全不受影响。

### 已做的处理

- **移除内部过程产物**：上游分析报告、内部改造工具链、本机运行脚本与 Redis 二进制、替换前备份、IDE/助手本地配置；
- **移除运行环境**：`node_modules`、`target`、`dist`、日志与本地配置（含本机数据库口令的 `application-local.yaml`、`docker.env`、`.env.env.local`）；
- **凭据脱敏**：仓库内所有示例/测试用的云厂商 AccessKey、短信与社交平台密钥、支付商户密钥、AI 平台 API Key 一律替换为 `REPLACE_WITH_YOUR_*` 占位符；
- **CI 自包含化**：修正对已移除内部脚本的引用，CI 不再依赖仓库外的工具。

### 已知边界

- **不承诺开箱跑通**：展示副本剔除了运行期产物，且 SQL 中的口令/密钥均为占位符，需自行补齐才能启动；
- **上游框架自带文档**：`fusion/**` 与 `fusion-ui-admin/**` 内的部分入门文档为上游随代码附带的框架说明，未逐一改写；
- **改造记录保留原貌**：`需求分析文档.md` 与 `docs/plans/` 是改造过程的真实记录，包含当时的阶段编号与决策依据，未做美化。

### 许可

- 上游为 **MIT 许可**，二次开发合规。原始版权声明保留在 `fusion/LICENSE`、`fusion/THIRD-PARTY-NOTICES.md`、`fusion-ui-admin/LICENSE`、`fusion-ui-admin/THIRD-PARTY-NOTICES.md`。
- 上游仓库链接与作者推广内容已移除。
