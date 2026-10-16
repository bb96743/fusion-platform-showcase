# ============================================================================
#  Fusion 后端镜像（多阶段：Maven 构建 → JRE 运行）
#
#  构建（上下文必须是整个 fusion\ 目录，因为是多模块工程）：
#    docker build -f fusion/fusion-server/Dockerfile -t fusion-server:1.0.0 fusion
#
#  或直接用根目录的 docker-compose.yml（推荐，会连 MySQL / Redis 一起编排）。
#
#  ⚠️ 本文件**尚未在真实 Docker 上验证过**（开发机未安装 Docker）。
#     已按常识处理：非 root 运行、健康检查、时区、JVM 参数可覆盖。
#     首次使用请先 `docker compose up -d mysql redis` 再起 server，并核对日志。
# ============================================================================

# ---------------------------------------------------------------------------
# 阶段 1：构建
# ---------------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src

# 先只拷 pom，利用镜像层缓存把依赖下载与源码变更分开
COPY pom.xml ./
COPY fusion-dependencies/pom.xml fusion-dependencies/
COPY fusion-framework/pom.xml   fusion-framework/
COPY fusion-server/pom.xml      fusion-server/
COPY fusion-module-system/pom.xml fusion-module-system/
COPY fusion-module-infra/pom.xml  fusion-module-infra/
COPY fusion-module-bpm/pom.xml    fusion-module-bpm/
COPY fusion-module-report/pom.xml fusion-module-report/
COPY fusion-module-ai/pom.xml     fusion-module-ai/
RUN mvn -B -q -pl fusion-server -am dependency:go-offline -DskipTests || true

# 再拷全部源码构建（-DskipTests：镜像构建不做回归，回归由 CI / _runtime\verify-all.ps1 负责）
COPY . .
RUN mvn -B -DskipTests clean package

# ---------------------------------------------------------------------------
# 阶段 2：运行
# ---------------------------------------------------------------------------
FROM eclipse-temurin:21-jre

# 健康检查与容器内自检需要 curl
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl tzdata \
 && rm -rf /var/lib/apt/lists/*

# 非 root 运行
RUN groupadd -r fusion && useradd -r -g fusion -u 10001 fusion \
 && mkdir -p /app/logs && chown -R fusion:fusion /app
WORKDIR /app

COPY --from=build --chown=fusion:fusion /src/fusion-server/target/fusion-server.jar /app/app.jar

ENV TZ=Asia/Shanghai
# -Duser.home=/app：application-prod.yaml 的日志路径是 ${user.home}/logs，
# 非 root 用户若 user.home=/ 会因无写权限而启动失败
ENV JAVA_OPTS="-Xms512m -Xmx1024m -Duser.home=/app -Djava.security.egd=file:/dev/./urandom"
ENV SPRING_PROFILES_ACTIVE=prod
ENV ARGS=""

USER fusion
EXPOSE 48080

# 启动约需 40~70 秒，故 start-period 给足
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
  CMD curl -fsS http://127.0.0.1:48080/actuator/health || exit 1

# 注意：不要用 shell 形式，否则 JAVA_OPTS 里的空格会被错误切分
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar $ARGS"]
