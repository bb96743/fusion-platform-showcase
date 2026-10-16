<template>
  <div ref="divRef" :class="['tinyflow', className]" :style="style" style="height: 100%"> </div>
</template>

<script setup lang="ts">
import { Item, Tinyflow as TinyflowNative } from './ui'
import './ui/index.css'
import { onMounted, onUnmounted, ref } from 'vue'

const props = defineProps<{
  className?: string
  style?: Record<string, string>
  data?: Record<string, any>
  provider?: {
    llm?: () => Item[] | Promise<Item[]>
    knowledge?: () => Item[] | Promise<Item[]>
    internal?: () => Item[] | Promise<Item[]>
  }
}>()

const divRef = ref<HTMLDivElement | null>(null)
let tinyflow: TinyflowNative | null = null
// 定义默认的 provider 方法
const defaultProvider = {
  llm: () => [] as Item[],
  knowledge: () => [] as Item[],
  internal: () => [] as Item[]
}

onMounted(() => {
  if (divRef.value) {
    // 合并默认 provider 和传入的 props.provider
    const mergedProvider = {
      ...defaultProvider,
      ...props.provider
    }
    tinyflow = new TinyflowNative({
      element: divRef.value as Element,
      data: props.data || {},
      provider: mergedProvider
    })
  }
})

onUnmounted(() => {
  if (tinyflow) {
    tinyflow.destroy()
    tinyflow = null
  }
})

const getData = () => {
  if (tinyflow) {
    return tinyflow.getData()
  }
  console.warn('Tinyflow instance is not initialized')
  return null
}

/**
 * 用一份新的 graph 替换整个画布（nodes / edges / viewport）。
 *
 * 为什么要暴露它：节点面板是 HTML5 拖拽（draggable + ondragstart）实现的，
 * 想「粘贴一份 JSON 直接建流程」就必须能整体灌数据；否则只能一个个节点拖。
 * 底层 `setData` 会销毁并重建画布组件，因此调用后拿到的 `getData()` 已是新数据。
 */
const setData = (data: Record<string, any>) => {
  if (tinyflow) {
    tinyflow.setData(data)
  } else {
    console.warn('Tinyflow instance is not initialized')
  }
}

defineExpose({
  getData,
  setData
})
</script>
