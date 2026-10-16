import { ref } from 'vue'
import * as ConfigApi from '@/api/infra/config'
import defaultLogo from '@/assets/imgs/logo.png'

/**
 * 项目 Logo（侧边栏与登录页共用）
 *
 * 背景：Logo 原先硬编码引用打包资源 `@/assets/imgs/logo.png`，换图必须改文件 + 重新构建。
 * 现在改为读后台「基础设施 → 项目配置」里上传的图片（配置键 `system.logo`）。
 *
 * 三个设计点：
 *  1. **模块级共享**：Logo 在侧边栏、登录页、二维码登录等多个组件里出现，
 *     这里用模块级 `ref` + 单例 Promise，保证**整个应用只请求一次**。
 *  2. **失败/为空一律回退内置图**：接口异常或后端尚未上传时，`logoUrl` 保持为
 *     `@/assets/imgs/logo.png`，所以**没配过 Logo 也不会出现裂图**。
 *  3. **不放进 Pinia 持久化**：URL 会随上传变化，缓存进 localStorage 只会拿到过期的图。
 *
 * 为什么只有一个版本、没有亮/暗切换：
 *   内置图是「品牌渐变圆角方盒 + **实心白色**四角火花」。方盒是不透明的渐变色，
 *   自身与深色侧边栏（#001529）和白底都有足够反差，**同一张图可直接用在两种背景上**，
 *   因此不需要分版本，也就不需要那个开关。
 *   （注：火花必须是实心白而非镂空 —— 镂空会透出背景色，放到深色侧边栏上星就变深色了。）
 *
 * 用法：
 * ```ts
 * const { logoUrl, loadLogo } = useLogoUrl()
 * onMounted(loadLogo)
 * // 模板里 :src="logoUrl"
 * ```
 */
const logoUrl = ref<string>(defaultLogo)

/** 单例请求：避免多个组件同时首次挂载时并发请求 */
let pending: Promise<void> | null = null

const doLoad = async () => {
  try {
    const url = (await ConfigApi.getLogoUrl()) as unknown as string
    // 后端未上传时返回空串 —— 此时保留内置图，不要赋空值造成裂图
    if (url && typeof url === 'string' && url.trim()) {
      logoUrl.value = url.trim()
    }
  } catch {
    // 静默回退：Logo 拿不到不应该阻断登录页或侧边栏的渲染
  }
}

/**
 * 加载 Logo（幂等，可安全地在多个组件的 onMounted 里调用）
 */
export const loadLogo = (): Promise<void> => {
  if (!pending) {
    pending = doLoad()
  }
  return pending
}

/**
 * 强制重新加载（上传成功后调用，让侧边栏与登录页立刻用上新图）
 */
export const reloadLogo = (): Promise<void> => {
  pending = doLoad()
  return pending
}

export const useLogoUrl = () => {
  return { logoUrl, loadLogo, reloadLogo }
}
