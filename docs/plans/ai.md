# AI 模块改造计划

| | |
|---|---|
| **归属会话** | AI 模块改造 |
| **当前状态** | 🟡 对话链路已打通（DeepSeek 端到端实测通过）；千问账号**仍欠费** + 其密钥已被使用者关闭 |
| **上游基线** | 后端 `master-jdk25 @ 21f5e82e51` |
| **最后更新** | 2026-10-12 |

---

## 1. 立项

- **业务目标**：自有产品里的 AI 能力（对话 / 写作 / 脑图 / 知识库 / 文生图）
- **保留范围**：AI 对话、AI 写作、AI 脑图、AI 知识库、AI 文生图、模型与密钥管理、角色仓库
- **明确不做**：Midjourney / Suno 等境外平台（除非确有需求）
- **验收标准**：14.4 清单全过 + 冒烟全绿 + **真实模型端到端回话**

## 2. 现状实测

| 项 | 实测值 | 备注 |
|---|---|---|
| `ai_chat_role` | 5 条（写作/导图/翻译/代码/通用助手），均有头像；`model_id` 全为 0（不绑定） | 来自迁移 `V001` + `V004` |
| `ai_model` | 2 条：`DeepSeek deepseek-chat`(sort=1) / `通义千问 Plus qwen-plus`(sort=0)，**两条 status 都是开启** | 只看这张表时「默认模型 = sort 最小 = 千问」 |
| `ai_api_key` | 2 条：DeepSeek `status=0`（开启，直连实测 200）；通义千问 `status=1`（**使用者已关闭**，账号仍欠费） | **模型与密钥是两张表、两个独立开关** |
| 实际生效的默认模型 | **DeepSeek**（2026-10-12 修复后） | 千问模型虽开启，但其密钥不可用 → 被跳过 |
| 冒烟 | `smoke-test.ps1` 含 AI 断言：角色存在、**角色都有头像**、**用角色建会话成功** | 只建会话不烧 token |

## 3. 已完成（历史记录见主文档 14.14 ~ 14.17）

| 项 | 内容 |
|---|---|
| 角色种子 | 原 `_tooling\12` 用 `UPDATE ... WHERE id=1..5`，全新库上一条也更新不到 → 改为幂等 `INSERT` 迁移 `V001` |
| 角色头像 | `avatar` 全为 NULL + 前端 `<img :src="role.avatar">` 无兜底 → `V004` 写入 `/ai-role/*.svg` + `RoleList.vue` 加兜底 |
| 「点『使用』报模型不存在」 | `ai_chat_role.model_id` 是 `NOT NULL DEFAULT 0`，0 = 用默认模型；代码却用 `!= null` 判断 → 改成 `getModel()` + 回退默认（`AiChatConversationServiceImpl`） |
| 千问对话必失败 | `spring-ai-alibaba 2.0.0-M1.1` 与 Spring AI **2.0.0** 不兼容（`ModelOptionsUtils.copyToTarget` 已不存在）→ 千问改走 DashScope **OpenAI 兼容端点**（`AiModelFactoryImpl` + `AiUtils.buildChatOptions` **两处必须成对改**） |
| 千问嵌入 / 文生图 | 另一会话完成：嵌入走兼容端点；文生图自研 `TongYiImageApi/Model/Options` 原生异步客户端；补「模型类型」守卫 |
| **默认模型指向已禁用密钥**（2026-10-12） | 根因：`ai_model.status` 与 `ai_api_key.status` 是**两张表的两个开关**，而默认模型选取只看前者 → 千问模型开着、密钥被使用者关掉，仍被选为默认模型，用户表现为「**每次新建对话，默认都是我已经关掉的那个模型**」，发消息才报「API 密钥已禁用！」。修复：① `getRequiredDefaultModel` 按 `sort` 升序遍历候选，**跳过密钥不可用的**（不存在 / 已禁用），一个都没有才报错；② 新增 `getAvailableModelOrNull(id)`，供 `chat` / `write` / `mindmap` 三个「角色显式绑定模型」的入口复用，绑定到坏模型时同样回退默认；③ 新增可读错误码 `1_040_001_004 = MODEL_DEFAULT_NOT_AVAILABLE`（提示用户去检查「模型配置 / API 密钥」两个开关） |
| 千问账号欠费（复核） | 2026-10-12 用库里密钥直连 `compatible-mode/v1/chat/completions` → **`400 Arrearage`**，仍未恢复；同批直连 DeepSeek → **200**，故当前以 DeepSeek 为可用链路 |
| **AI 工作流「大模型」节点一个都跑不起来**（2026-10-12） | 实测两个模型都失败：`llmId=1`(DeepSeek) → `NullPointerException: "this.llm" is null`（`agents-flex` `LlmNode.execute`）；`llmId=2`(千问) → `1040000001 API 密钥已禁用！`。根因：`AiModelServiceImpl#getLLmProvider4Tinyflow` 的 switch **只处理 TONG_YI / OLLAMA**，DeepSeek 平台没接线 → tinyflow 拿到空 provider，界面只显示「系统异常」。**修复**：新增 `case DEEP_SEEK:`，用类路径上已有的 `agents-flex-llm-deepseek`（`DeepseekConfig` + `DeepseekLlm`，与 TONG_YI 分支同构；库里的 url 非空时覆盖默认端点），并给 `default` 加日志（便于下次定位「工作流跑不动」） |

## 4. 待办

| 优先级 | 事项 | 说明 |
|---|---|---|
| ★★★ | **非流式 `/send` 稳定 500（已定位，未修）** | `spring-ai-deepseek-2.0.0` 解析 DeepSeek 响应时抛 `HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input`（Jackson 3）。**已隔离复现**：脱离 Fusion 代码直连 `DeepSeekChatModel` 同样失败，而同样请求 `curl` 返回合法 JSON → **属依赖组合问题，不是本模块代码问题**。前端走的是流式 `/send-stream`（正常），故影响面限于直接调 `/send` 的调用方。待查：是否与运行在 JDK 21（基线为 JDK 25）有关 |
| ★★★ | **历史上下文不带模型隔离（已定位，未修）** | `AiChatMessageServiceImpl#filterContextMessages` 取最近 N 轮历史时**不区分 `model` 字段**，切换模型后旧历史会把上一个模型的自我认知喂给新模型 → 表现为「已经换成 DeepSeek 了，回答却仍自称千问」。实测：同一会话关掉上下文（`useContext=false`）时 DeepSeek 正确自称 DeepSeek。修法建议：只取与当前 `modelId` 一致的历史，或切换模型时切分会话（涉及会话语义，需单独一轮） |
| ★★★ | **充值后复验对话 / 复验嵌入与文生图** | 千问侧仍 `400 Arrearage`（2026-10-12 复核）；文生图与嵌入目前只有 mock 测试，未打真实接口 |
| ★★☆ | 摘上游前端 `89795c5db` | **XSS**：MarkdownView 用模型输出拼 HTML 前必须转义 —— 我们正用它渲染**不可信**的模型输出（已核实：`MarkdownView/index.vue` 第 27 行仍是未转义的 `data-copy='${str}'`） |
| ★★☆ | 摘上游前端 `25b0552a7` | 同一组件：补齐代码块语言标签与复制按钮 |
| ★☆☆ | 摘上游后端 `d1937e4330` | `AiWorkflowDO` 自增序号（已核实：仍为 `@KeySequence("ai_workflow")`，应为 `ai_workflow_seq`） |
| ★☆☆ | 模型表单加校验 | 「模型标识」填错时只报 404，界面上应给出可选模型列表或格式提示 |
| ★★☆ | 工作流的其余平台接线 | `getLLmProvider4Tinyflow` 现只支持 TONG_YI / OLLAMA / DEEP_SEEK；其余平台走 `default` 只打日志（不再抛 NPE，但节点仍不可用）。若将来上其他平台，按同样方式补 `case` |

## 5. 别再踩的坑

1. **`ai_chat_role.model_id` 用 0 表示「不绑定、用默认模型」**，且列是 `NOT NULL` —— 判断必须 `> 0`，不能 `!= null`。
2. **默认模型 = `type=聊天 AND status=开启 ORDER BY sort ASC LIMIT 1`**，不是按 id。⚠️ 2026-10-12 起口径修正：**还必须跳过「绑定的 API 密钥不可用」的候选**（见第 6 条）。
3. **DashScope 家族（通义千问 / 嵌入 / 文生图）必须走兼容端点或自研客户端**；原生 `spring-ai-alibaba` SDK 在当前版本组合下必抛 `NoSuchMethodError`。将来 `spring-ai-alibaba` 版本对齐后可改回（代码里留了常量与注释）。
4. **建临时验证账号时注意：登录账号名只允许字母和数字**（`zz-verify-tmp` 会被参数校验拦下）。
5. 测 AI 用临时账号 + 测完清理，不要动使用者的管理员口令（做法见主文档 14.15.4）。
6. **「模型」和「API 密钥」是两个独立开关，分别在两张表**：`ai_model.status` 与 `ai_api_key.status`。
   **在界面上关掉密钥 ≠ 关掉模型** —— 关密钥只影响「能不能调出去」，不影响「会不会被选为默认模型」。
   历史上正因为只看 `ai_model.status`，才出现「默认模型永远是我已经关掉的那个」。
   排查这类问题时**两张表都要查**，别只看一边。
7. **同一个会话切换模型后，历史消息不会跟着清**；而历史会被当作上下文下发（`filterContextMessages` 不按 `model` 过滤）→
   新模型可能顺着旧模型的自述继续答（例如已切到 DeepSeek 却仍自称千问）。判定方法：
   同一会话把「使用上下文」关掉再问一次，若回答正确即为此问题。
8. **用 `FusionDbTool` 读含中文的长文本（如 `ai_workflow.graph`）时，控制台会按 GBK 解码 → 输出乱码、长度也失真**
   （实测：同一份 graph，控制台侧字符串长度 1210，而 MySQL 的 `CHAR_LENGTH` 是 1147、`LENGTH` 是 1373）。
   **要报数字就用 SQL 的 `CHAR_LENGTH` / `LENGTH` 去量**，不要拿本地字符串长度当证据；
   本次就因此差点把一个错数字写进文档（已更正）。需要原文时走接口（JSON 管道）而不是控制台回显。

## 6. 「默认模型指向已禁用密钥」的验证证据（2026-10-12）

改动文件：

| 文件 | 改动 |
|---|---|
| `AiModelServiceImpl` | `getRequiredDefaultModel` 改为按 `sort` 升序遍历已开启模型、跳过密钥不可用者；新增 `getAvailableModelOrNull`、私有 `isApiKeyAvailable` |
| `AiModelService` | 接口新增 `getAvailableModelOrNull` |
| `AiChatConversationServiceImpl` | 角色绑定模型改用 `getAvailableModelOrNull`（坏模型回退默认） |
| `AiWriteServiceImpl` / `AiMindMapServiceImpl` | 同上（保持一致） |
| `ErrorCodeConstants` | 新增 `MODEL_DEFAULT_NOT_AVAILABLE = 1_040_001_004` |
| `AiChatMapper` | **删除**已无调用方的 `selectFirstByStatus(type, status)`（它只看模型状态、不看密钥，正是本 bug 的入口），并清掉随之失效的 import |
| `AiModelServiceDefaultModelMockTest`（新增） | 9 例回归测试 |

验证结果（命令 + 数字）：

| 项 | 命令 | 结果 |
|---|---|---|
| 新增单测 | `mvn -o -pl fusion-module-ai test -Dtest=AiModelServiceDefaultModelMockTest` | **Tests run: 9, Failures: 0, Errors: 0** |
| 与既有 mock 测试合计 | 加跑 `TongYiImageModelMockTest,TongYiEmbeddingModelMockTest` | **13 / 13 通过** |
| 全量后端构建 | `mvn -o clean package -DskipTests` | **BUILD SUCCESS** |
| 运行时：新建对话 | `POST /ai/chat/conversation/create-my` 空体 | 选中 **`modelId=1 deepseek-chat`**（修复前为 `modelId=2 qwen-plus`） |
| 运行时：真实回话 | `POST /ai/chat/message/send-stream` | **code=0**，DeepSeek 回复自称 DeepSeek |
| 运行时：角色绑定坏模型 | 临时置 `ai_chat_role.model_id=2`（密钥禁用） | **回退**为 `modelId=1`（修复前选中 `modelId=2`） |
| 运行时：角色绑定好模型 | 两把密钥都开启时置 `model_id=1` | 仍选 **`modelId=1`**（尊重绑定，未被改成「永远用默认」）；对照组空角色 → `modelId=2`（sort 最小） |
| 运行时：边界 | 两把密钥都禁用后新建对话 | **code=1040001004** + 可读提示（不再是含糊的「找不到默认模型」） |
| 冒烟回归 | `_runtime\smoke-test.ps1` | **30 / 30 通过** |
| 直连实测 | 千问 `compatible-mode/v1/chat/completions` | **400 Arrearage**（仍未充值） |
| 直连实测 | DeepSeek `chat/completions` | **200**（可用） |

> 验证后已还原使用者配置（千问密钥保持关闭、角色 `model_id` 回到 0），并清理本次新建的会话与消息，
> 数据库只剩使用者自己的会话 `id=3`。

## 7. AI 工作流：图格式、演示与工具限制（2026-10-12）

### 7.1 数据契约（逆向自 `tinyflow-java-core 1.2.6` + 前端 bundle，已实测跑通）

工作流的 `graph` 就是 Svelte Flow 的 `{nodes, edges, viewport}`。节点类型与 `data` 字段：

| 节点 `type` | `data` 关键字段 | 说明 |
|---|---|---|
| `startNode` | `parameters: [{name, dataType, required, description, defaultValue}]` | 定义输入参数（测试面板会自动带出「required」的参数） |
| `llmNode` | `llmId`（`ai_model.id`）、`systemPrompt`、`userPrompt`、`outType`（`text`/`json`）、`parameters` | **提示词写 `{{参数名}}`**（模板正则 `\{\{\s*(.+?)\s*}}`）；变量要靠本节点的 `parameters` 映射：`[{name, dataType, refType:'ref', ref:'<startNodeId>.<参数名>'}]` —— 只写 `{{topic}}` 而不做映射**不会生效**（实测：会当成字面量，模型自行发挥） |
| `endNode` | `outputDefs: [{name, dataType, refType:'ref', ref:'<llmNodeId>.output'}]` | 输出**靠 `outputDefs`**，`message` 只用于 `chain.stopNormal/stopError` 的结束语，**不是返回内容**（踩过：只写 `message` 时接口返回 `data:{}`） |

`refType` 取值是小写：`ref` / `fixed` / `input`（`RefType.ofValue`）。LLM 节点的输出变量名固定为 `output`。

### 7.2 演示：古诗词创作工作流（浏览器实测全流程）

流程：`开始节点(输入 诗词主题) → 大模型(DeepSeek，写七言绝句) → 结束节点(输出 poem)`。

| 环节 | 结果 |
|---|---|
| 列表页 | 「古诗词创作」(`code=gushici`, id=2) 与既有的 `test` 并列显示 |
| 设计器 | 三个节点与两条连线正确渲染（`Edge from start_1 to llm_1`、`Edge from llm_1 to end_1`） |
| 测试面板 | 自动带出参数「诗词主题」，默认值 `春天`；改为 `荷花` |
| 运行结果 | `{"poem":"翠盖摇风映碧波，红妆照水暗香多。\n污泥不染真君子，一片冰心入棹歌。"}` |
| 保存 | 提示「保存成功」并回到列表 |

截图证据（本地，`_analysis/_scratch` 不入库）：`_analysis\_scratch\workflow-demo\01-workflow-list.jpg`、`02-designer-flow.jpg`、`03-test-drawer-param.jpg`、`04-run-result-poem.jpg`。

### 7.3 建模入口：「拖拽」与「导入 JSON」并存

**背景（工具限制）**：节点面板是 HTML5 拖拽实现（`draggable:!0` + `ondragstart` 写入
`dataTransfer['application/tinyflow']`），而自动化浏览器工具集只有点击/输入/滚动，
**没有拖拽动作** → 无法用脚本把节点拖进画布。7.2 的演示里「建记录 + 写入 graph」
是通过 `POST /admin-api/ai/workflow/create` 完成的。

**已补的入口（2026-10-12）**：设计器工具栏新增 **「导入 JSON」**（在「测试」左侧）：

| 项 | 说明 |
|---|---|
| 位置 | `WorkflowDesign.vue` 工具栏；配套 `Tinyflow.vue` 暴露 `setData(data)`（底层会销毁并重建画布组件，`getData()` 随即返回新数据） |
| 打开时 | 预填**当前画布**的 graph（`JSON.stringify(getData(), null, 2)`），便于在现有基础上微调 |
| 校验 | ① 必须是合法 JSON（否则报 `JSON 解析失败：...`）；② 必须含 `nodes` 数组（否则报「格式不正确」）；`edges` 缺省时自动补 `[]` |
| 生效范围 | **只覆盖画布**，不自动入库；仍要点右上角「保 存」才写库（弹窗里已用提示写明） |
| 按钮 | 「清 空」/「取 消」/「导 入」 |

**验证（浏览器实测，2026-10-12）**：

| 步骤 | 结果 |
|---|---|
| 打开弹窗 | 预填当前 graph（可滚动查看） |
| 负向：填 `{oops 这不是合法 JSON` → 导入 | 被拦下，**画布不变**、弹窗保持打开 |
| 正向：导入改过的图（节点改名为 ① 输入主题 / ② 大模型写诗 / ③ 输出诗词，默认主题改 `梅花`） | 画布**即时替换**为新节点名与连线 |
| 保存 | 提示「保存成功」；库里 `graph` 可解析为 **3 节点 / 2 连线**（MySQL 侧 `CHAR_LENGTH`=1147、`LENGTH`=1373） |
| 重新打开 | 导入的节点名已持久化；测试面板参数**自动带出新默认值 `梅花`** |
| 运行 | `{"poem":"冰雪林中著此身，不同桃李混芳尘。\n忽然一夜清香发，散作乾坤万里春。"}` |

截图证据：`_analysis\_scratch\workflow-demo\05-import-json-applied.jpg`、`06-imported-graph-run.jpg`、
`07-import-invalid-json-toast.jpg`、`08-import-success-toast.jpg`。

> ⚠️ **本次踩的坑（值得记住）**：第一版忘了 `const message = useMessage()`。
> 浏览器里看起来「能用」——因为 `message.xxx()` 抛 `ReferenceError` 时，
> **坏消息是它发生在状态变更之后**（`setData` 已执行、弹窗已关闭），于是「导入成功、画布已更新」的表象全对，
> 只有提示没弹、控制台多一条报错。是 **`pnpm run ts:check` 把它抓出来的**（`TS2304: Cannot find name 'message'`）。
> 教训：**验证前端改动别只看"页面行为对不对"，一定要跑类型检查** —— 缺失的引用会被运行时静默吞掉一半。
> （修完后复测：错误/成功两条提示都正常弹出，见 07/08 号截图。）

> 有了这个入口，**自动化可以完全不依赖拖拽**地建模（粘贴 graph → 导入 → 保存），
> 也方便把工作流 JSON 在环境之间搬运 / 走代码评审。
