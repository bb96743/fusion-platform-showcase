<script lang="ts" setup>
import { computed, onMounted, ref, unref, watch } from 'vue'
import { useAppStore } from '@/store/modules/app'
import { useDesign } from '@/hooks/web/useDesign'
import { useLogoUrl } from '@/hooks/web/useLogoUrl'
import { getLayoutRenderMode, isHeaderNavLayout } from '@/utils/layout'

defineOptions({ name: 'Logo' })

const { getPrefixCls } = useDesign()

const prefixCls = getPrefixCls('logo')

const appStore = useAppStore()

// 项目 Logo：读后台「基础设施 → 项目配置」上传的图，未上传时回退内置 logo.png
const { logoUrl, loadLogo } = useLogoUrl()

const show = ref(true)

const title = computed(() => appStore.getTitle)

/**
 * 「品牌 + 业务定位」拆成两行排版。
 *
 * 为什么：侧边栏宽度固定（logo + 内边距占掉后只剩约 160px），
 * 像 `Fusion 数智业务中台` 这样的标题在 16px 粗体下放不下，会被浏览器**折行**成
 * 「Fusion 数智业务中 / 台」这种难看的样子。与其缩小字号硬塞，不如拆成有意的两行。
 *
 * 约定：标题里**第一个空格之前**是品牌名，之后是业务定位。
 *       没有空格时按单行渲染（见模板里的 `v-else` 分支）。
 */
const titleParts = computed(() => {
  const raw = (unref(title) ?? '').trim()
  const idx = raw.search(/\s/)
  if (idx <= 0) {
    return { brand: raw, sub: '' }
  }
  return { brand: raw.slice(0, idx), sub: raw.slice(idx + 1).trim() }
})

const layout = computed(() => appStore.getLayout)

const collapse = computed(() => appStore.getCollapse)

onMounted(() => {
  if (unref(collapse)) show.value = false
  // 拉取项目 Logo（幂等，多组件共用同一次请求）
  loadLogo()
})

watch(
  () => collapse.value,
  (collapse: boolean) => {
    if (
      getLayoutRenderMode(unref(layout)) === 'topLeft' ||
      getLayoutRenderMode(unref(layout)) === 'cutMenu'
    ) {
      show.value = true
      return
    }
    if (!collapse) {
      setTimeout(() => {
        show.value = !collapse
      }, 400)
    } else {
      show.value = !collapse
    }
  }
)

watch(
  () => layout.value,
  (layout) => {
    const renderMode = getLayoutRenderMode(layout)
    if (renderMode === 'top' || renderMode === 'cutMenu') {
      show.value = true
    } else {
      if (unref(collapse)) {
        show.value = false
      } else {
        show.value = true
      }
    }
  }
)
</script>

<template>
  <div>
    <router-link
      :class="[
        prefixCls,
        getLayoutRenderMode(layout) !== 'classic' ? `${prefixCls}__Top` : '',
        'flex !h-[var(--logo-height)] items-center cursor-pointer pl-8px relative decoration-none overflow-hidden'
      ]"
      to="/"
    >
      <img
        class="h-[calc(var(--logo-height)-10px)] w-[calc(var(--logo-height)-10px)]"
        :src="logoUrl"
      />
      <div
        v-if="show"
        :class="[
          'ml-10px flex flex-col justify-center leading-tight overflow-hidden',
          {
            'text-[var(--logo-title-text-color)]': getLayoutRenderMode(layout) === 'classic',
            'text-[var(--top-header-text-color)]':
              getLayoutRenderMode(layout) === 'topLeft' ||
              isHeaderNavLayout(layout) ||
              getLayoutRenderMode(layout) === 'cutMenu'
          }
        ]"
      >
        <!-- 有业务定位时：品牌一行（大、粗）+ 定位一行（小、浅），两行都是有意的排版 -->
        <template v-if="titleParts.sub">
          <span class="text-15px font-700 whitespace-nowrap">{{ titleParts.brand }}</span>
          <span class="text-11px font-400 opacity-75 whitespace-nowrap">{{ titleParts.sub }}</span>
        </template>
        <!-- 没有空格时按单行渲染；nowrap + ellipsis 作为兜底，任何标题都不会再折行 -->
        <span v-else class="text-16px font-700 whitespace-nowrap overflow-hidden text-ellipsis">
          {{ titleParts.brand }}
        </span>
      </div>
    </router-link>
  </div>
</template>
