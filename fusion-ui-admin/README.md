# Fusion 管理后台（前端）

Fusion 项目的管理后台前端，基于 Vue 3 + Vite + Element Plus + TypeScript。

> 本项目代码基座来自开源项目（MIT 许可）的二次开发，原始版权声明见
> [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)。上游作者推广内容与外部仓库链接已移除。

---

## 环境要求

| 项 | 版本 |
|---|---|
| Node.js | >= 20.19.0 |
| pnpm | >= 8.6.0 |

## 命令

```bash
pnpm install        # 安装依赖
pnpm dev            # 本地开发（读取 .env.local）
pnpm build:prod     # 生产构建（输出 dist-prod）
pnpm ts:check       # TypeScript 类型检查
pnpm lint           # ESLint + Stylelint + Prettier
```

> 依赖安装脚本（`esbuild`、`@parcel/watcher` 等）由 `pnpm-workspace.yaml` 中的
> `allowBuilds` 显式放行。若 pnpm 提示 *Ignored build scripts*，说明该配置被改动过。

## 技术栈

Vue 3.5 · Vite 8 · Element Plus 2.13 · TypeScript 6 · Pinia 3 · Vue Router 5 ·
UnoCSS · vue-i18n · ECharts 6 · bpmn-js（工作流设计器）

## 目录结构

```
src
├── api          后端接口封装（按业务模块分层）
├── assets       图片 / SVG / 音视频等静态资源
├── components   通用与业务组件
├── config       axios 封装、全局配置
├── directives   自定义指令
├── hooks        组合式函数
├── layout       布局（侧边栏 / 顶栏 / 标签页 / 用户信息）
├── locales      国际化（zh-CN / en）
├── plugins      插件注册
├── router       路由定义与守卫
├── store        Pinia 状态
├── styles       全局样式
├── types        TypeScript 类型
├── utils        工具函数
└── views        页面
```

**保留的页面模块**：`system`（系统管理）、`infra`（基础设施）、`bpm`（工作流）、
`report`（报表大屏）、`ai`（AI 能力），以及 `Login` / `Home` / `Profile` / `Error` /
`Redirect` / `IFrame` 等框架页面。

## 环境文件与加载顺序

`pnpm dev` 等价于 `vite --mode env.local`，`pnpm build:prod` 等价于 `vite --mode prod`。
Vite 按「后者覆盖前者」的顺序加载：

| 文件 | 由谁加载 | 是否入库 | 该放什么 |
|---|---|---|---|
| `.env` | 所有模式 | ✅ | 共享项：标题、端口、功能开关 |
| `.env.local` | **所有模式都会加载**（含 `build:prod`） | ✅ | 只能放非敏感、非环境专属的值 |
| `.env.env.local` | `pnpm dev`（`--mode env.local`） | ❌ **不入库** | **本地开发专用**：预填的登录账号与口令 |
| `.env.env.local.example` | —— | ✅ | 上面那个文件的模板，首次复制过去并填口令 |
| `.env.dev` | `pnpm dev-server` / `build:dev` | ✅ | dev 环境 |
| `.env.test` | `build:test` | ✅ | 测试环境 |
| `.env.stage` | `build:stage` | ✅ | 预发环境 |
| `.env.prod` | `pnpm build:prod`（`--mode prod`） | ✅ | 生产（`VITE_BASE_URL` 留空 = 同源） |

> ⚠️ **首次克隆必须先复制模板**（`.env.env.local` 不入库 —— 它含管理员口令）：
>
> ```powershell
> copy .env.env.local.example .env.env.local
> ```
>
> 或直接跑 `..\_runtime\check-env.ps1 -Fix`，它会自动补齐。

> ⚠️ **千万别把账号密码写进 `.env.local`** —— 它会被 `build:prod` 一起打进生产包
> （本项目实测踩过这个坑）。本地预填值只能写在 `.env.env.local`。
>
> ⚠️ `.env.env.local` 里的 `VITE_APP_DEFAULT_LOGIN_TENANT` 必须与数据库中
> `system_tenant.name` **完全一致**（当前为 `Fusion 管理平台`），
> 否则登录会报「请求的租户标识未传递」。

本地开发默认账号：`admin`，口令见 `.env.env.local` 的 `VITE_APP_DEFAULT_LOGIN_PASSWORD`
（F0 已把上游弱口令 `123456` 替换为随机强口令；库中也只剩这一个账号）。

## 环境变量

| 变量 | 说明 |
|---|---|
| `VITE_APP_TITLE` | 系统标题 |
| `VITE_BASE_URL` | 后端接口地址（空值 = 同源，配合 nginx 反向代理） |
| `VITE_API_URL` | 接口前缀，默认 `/admin-api` |
| `VITE_BASE_PATH` | 部署子路径（**必须是路径，不能是完整 URL**） |
| `VITE_UPLOAD_TYPE` | 上传方式：`server`（后端中转）/ `client`（前端直连，仅 S3） |
| `VITE_APP_TENANT_ENABLE` | 是否启用多租户 |
| `VITE_APP_CAPTCHA_ENABLE` | 是否启用登录验证码 |
| `VITE_APP_DEFAULT_LOGIN_TENANT` / `_USERNAME` / `_PASSWORD` | 登录页预填值，**只应出现在 `.env.env.local`** |
| `VITE_GOVIEW_URL` | GoView 大屏地址（report 模块使用） |
| `VITE_APP_API_ENCRYPT_*` | 接口加解密，需与后端 `fusion.api-encrypt.*` 保持一致 |

> ⚠️ **遗留项**：`VITE_GOVIEW_URL` 目前在 `.env.prod` 里仍是 `http://127.0.0.1:3000`，
> 会把本机地址打进生产包（`dist-prod` 产物已实测命中）。部署前必须按环境改成真实地址。
> 另：`.env.local` / `.env.dev` 中残留的 `VITE_MALL_H5_DOMAIN` 对应的商城模块已删除，属可清理项。

## 品牌资源

- `public/favicon.ico`、`public/logo.gif`
- `src/assets/imgs/logo.png`、`src/assets/imgs/avatar.{png,gif}`

以上文件由 `../_tooling/08-generate-branding.ps1` 生成，可随时替换为自有设计。

---

## 后续改造

本项目目前处于**第二阶段：自有品牌业务化**（第一阶段「把上游改造成自有品牌」已完成）。
模块改造顺序、单模块标准流程（SOP）与进度看板见 `../需求分析文档.md` **第 14 章**。

按模块改造前端时，重点遵守 14.4 的第 ④⑤ 步：

- `src/api/<模块>` 与 `src/views/<模块>` **必须成对**增删；
- **`system_menu.component` 必须能解析到真实文件** —— 本项目的动态路由是
  `import.meta.glob` 的**子串匹配**，删除页面**不会报构建错误**，只会在运行时渲染出一片空白；
- 删/改模块必须同步 4 处：`views`、`api`、静态路由、`system_menu` + `system_role_menu`。

---

## 许可

MIT。原始版权声明见 [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)。
