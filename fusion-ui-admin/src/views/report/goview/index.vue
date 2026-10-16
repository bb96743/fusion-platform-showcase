<template>
  <ContentWrap :bodyStyle="{ padding: '0px' }" class="!mb-0">
    <IFrame v-if="src" :src="src" />
    <div v-else class="p-40px text-center text-gray-500">
      未配置 GoView 大屏地址（环境变量 VITE_GOVIEW_URL），请在对应的 .env 文件中配置后重新构建。
    </div>
  </ContentWrap>
</template>
<script lang="ts" setup>
import { getAccessToken } from '@/utils/auth'

defineOptions({ name: 'GoView' })

/**
 * GoView 大屏地址。
 *
 * ⚠️ 安全说明
 *   上游原本会把 **accessToken 与 refreshToken 一起**拼在 iframe 的 URL 上。
 *   这等于把长期凭据写进 URL：浏览器历史、Referer 头、以及 GoView 侧的访问日志
 *   都会记录它，一旦泄露可以用 refreshToken 持续换取新的 accessToken。
 *
 *   本处已移除 **refreshToken**（长期凭据），只保留 accessToken（短期有效）。
 *
 * ⚠️ 残留风险与后续做法（列入 F4 report 模块改造）
 *   即便只传 accessToken，放在 URL 查询串里仍不理想。推荐二选一：
 *     ① 由后端代理 GoView 并注入令牌，前端完全不接触令牌；
 *     ② GoView 与后台**同域部署**，走同源 Cookie 会话，URL 上不传任何令牌。
 *
 * ⚠️ 环境变量
 *   `VITE_GOVIEW_URL` 必须按环境分别配置。生产环境**不能**保留 127.0.0.1，
 *   否则会把本机地址打进生产包。
 */
const goviewUrl = import.meta.env.VITE_GOVIEW_URL
const src = goviewUrl ? `${goviewUrl}?accessToken=${getAccessToken()}` : ''
</script>
