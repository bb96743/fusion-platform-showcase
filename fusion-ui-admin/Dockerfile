# ============================================================================
#  Fusion 前端镜像（多阶段：Node 构建 → nginx 静态托管）
#
#  构建：
#    docker build -t fusion-admin:1.0.0 fusion-ui-admin
#
#  或直接用根目录的 docker-compose.yml（推荐）。
#
#  ⚠️ 本文件**尚未在真实 Docker 上验证过**（开发机未安装 Docker）。
#
#  说明：构建时的环境变量取自仓库里已提交的 `.env.prod`（`pnpm build:prod` 即 `--mode prod`），
#  因此**不需要**在这里传 VITE_* 构建参数 —— 这样就与本地构建用的是同一套配置，
#  不会出现「镜像里的地址和本地不一样」。要改地址请改 `.env.prod` 后重建。
# ============================================================================

# ---------------------------------------------------------------------------
# 阶段 1：构建
# ---------------------------------------------------------------------------
FROM node:22-alpine AS build
WORKDIR /src

RUN npm i -g pnpm@11

# pnpm-workspace.yaml 必须一起拷：它里面配置了 allowBuilds（esbuild 等安装脚本的白名单），
# 缺了它 pnpm 会拒绝执行构建脚本，导致本地/镜像行为不一致。
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build:prod

# ---------------------------------------------------------------------------
# 阶段 2：运行
# ---------------------------------------------------------------------------
FROM nginx:1.27-alpine

# 时区
RUN apk add --no-cache tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo "Asia/Shanghai" > /etc/timezone

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/dist-prod /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
