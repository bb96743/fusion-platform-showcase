<template>
  <div class="relative" style="width: 100%; height: 700px">
    <Tinyflow
      v-if="workflowData"
      ref="tinyflowRef"
      :className="'custom-class'"
      :style="{ width: '100%', height: '100%' }"
      :data="workflowData"
      :provider="provider"
    />
    <div class="absolute top-30px right-30px flex gap-2">
      <el-button @click="openImportDialog"> 导入 JSON </el-button>
      <el-button @click="testWorkflowModel" type="primary" v-hasPermi="['ai:workflow:test']">
        测试
      </el-button>
    </div>

    <!-- 导入 JSON：节点面板是拖拽式的，这里给一条「粘贴 graph 直接建流程」的通道 -->
    <el-dialog v-model="showImportDialog" title="导入工作流 JSON" width="660px" append-to-body>
      <el-alert type="info" :closable="false" class="mb-10px">
        <template #title>
          粘贴 Tinyflow 的 graph JSON（形如 <code>{ nodes, edges, viewport }</code>）。
          <b>确认后覆盖当前画布</b>，导入的内容不会自动入库，仍需点右上角「保 存」。
        </template>
      </el-alert>
      <el-input
        v-model="importText"
        type="textarea"
        :rows="16"
        spellcheck="false"
        placeholder="在此粘贴 graph JSON，例如 { nodes: [ ... ], edges: [ ... ] }"
      />
      <div class="mt-10px text-12px text-[var(--el-text-color-secondary)]">
        校验：必须是合法 JSON，且含 <code>nodes</code> 数组。
      </div>
      <template #footer>
        <el-button @click="importText = ''">清 空</el-button>
        <el-button @click="showImportDialog = false">取 消</el-button>
        <el-button type="primary" @click="doImport">导 入</el-button>
      </template>
    </el-dialog>

    <!-- 测试窗口 -->
    <el-drawer v-model="showTestDrawer" title="工作流测试" :modal="false">
      <fieldset>
        <legend class="ml-15px"><h3>运行参数配置</h3></legend>
        <div class="p-20px">
          <div
            class="flex justify-around mb-10px"
            v-for="(param, index) in params4Test"
            :key="index"
          >
            <el-select class="w-200px!" v-model="param.key" placeholder="参数名">
              <el-option
                v-for="(value, key) in paramsOfStartNode"
                :key="key"
                :label="value?.description || key"
                :value="key"
                :disabled="!!value?.disabled"
              />
            </el-select>
            <el-input class="w-200px!" v-model="param.value" placeholder="参数值" />
            <el-button type="danger" plain :icon="Delete" circle @click="removeParam(index)" />
          </div>
          <!-- TODO @lesan：是不是不用添加和删除参数，直接把必填和选填列出来，然后加上参数校验？ -->
          <el-button type="primary" plain @click="addParam">添加参数</el-button>
        </div>
      </fieldset>
      <fieldset class="mt-20px bg-#f8f9fa">
        <legend class="ml-15px"><h3>运行结果</h3></legend>
        <div class="p-20px">
          <div v-if="loading"> <el-text type="primary">执行中...</el-text></div>
          <div v-else-if="error">
            <el-text type="danger">{{ error }}</el-text>
          </div>
          <pre v-else-if="testResult" class="result-content">
            {{ JSON.stringify(testResult, null, 2) }}
          </pre>
          <div v-else> <el-text type="info">点击运行查看结果</el-text> </div>
        </div>
      </fieldset>
      <el-button class="mt-20px w-100%" size="large" type="success" @click="goRun">
        运行流程
      </el-button>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import Tinyflow from '@/components/Tinyflow/Tinyflow.vue'
import * as WorkflowApi from '@/api/ai/workflow'
// TODO @lesan：要不使用 ICon 哪个组件哈
import { Delete } from '@element-plus/icons-vue'

defineProps<{
  provider: any
}>()

type WorkflowParam = {
  key: string
  value: string
}

type StartNodeParameter = {
  name: string
  dataType: string
  description?: string
  disabled?: boolean
  required?: boolean
  defaultValue?: string
}

const tinyflowRef = ref()
const workflowData = inject('workflowData') as Ref
const showTestDrawer = ref(false)
const params4Test = ref<WorkflowParam[]>([])
const paramsOfStartNode = ref<Record<string, StartNodeParameter>>({})
const testResult = ref(null)
const loading = ref(false)
const error = ref<string | null>(null)
const message = useMessage() // 消息弹窗

/** 展示工作流测试抽屉 */
const testWorkflowModel = () => {
  showTestDrawer.value = !showTestDrawer.value
}

// ========== 导入 JSON ==========

const showImportDialog = ref(false)
const importText = ref('')

/** 打开导入弹窗：预填当前画布内容，便于在此基础上微调 */
const openImportDialog = () => {
  try {
    const current = tinyflowRef.value?.getData()
    importText.value = current ? JSON.stringify(current, null, 2) : ''
  } catch (e) {
    importText.value = ''
  }
  showImportDialog.value = true
}

/** 执行导入：校验 → 覆盖画布 */
const doImport = () => {
  const text = importText.value.trim()
  if (!text) {
    message.warning('请先粘贴 graph JSON')
    return
  }
  // 1. 必须是合法 JSON
  let data: any
  try {
    data = JSON.parse(text)
  } catch (e) {
    message.error(`JSON 解析失败：${e instanceof Error ? e.message : String(e)}`)
    return
  }
  // 2. 必须含 nodes 数组（否则画布会空掉且不知道为什么）
  if (!data || typeof data !== 'object' || !Array.isArray(data.nodes)) {
    message.error('格式不正确：缺少 nodes 数组')
    return
  }
  if (!Array.isArray(data.edges)) {
    // edges 允许缺省，补空数组，避免底层报错
    data.edges = []
  }
  // 3. 覆盖画布，并同步给上层（保存时用的就是 workflowData）
  try {
    tinyflowRef.value.setData(data)
    workflowData.value = data
    showImportDialog.value = false
    message.success(
      `已导入 ${data.nodes.length} 个节点、${data.edges.length} 条连线，请点「保 存」生效`
    )
  } catch (e) {
    message.error(`导入失败：${e instanceof Error ? e.message : String(e)}`)
  }
}

/** 运行流程 */
const goRun = async () => {
  try {
    const val = tinyflowRef.value.getData()
    loading.value = true
    error.value = null
    testResult.value = null
    /// 查找start节点
    const startNode = getStartNode()

    // 获取参数定义
    const parameters = startNode.data?.parameters || []
    const paramDefinitions: Record<string, string> = {}
    parameters.forEach((param: StartNodeParameter) => {
      paramDefinitions[param.name] = param.dataType
    })

    // 参数类型转换
    const convertedParams = {}
    for (const { key, value } of params4Test.value) {
      const paramKey = key.trim()
      if (!paramKey) continue

      let dataType = paramDefinitions[paramKey]
      if (!dataType) {
        dataType = 'String'
      }

      try {
        convertedParams[paramKey] = convertParamValue(value, dataType)
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e)
        throw new Error(`参数 ${paramKey} 转换失败: ${message}`)
      }
    }

    const data = {
      graph: JSON.stringify(val),
      params: convertedParams
    }

    const response = await WorkflowApi.testWorkflow(data)
    testResult.value = response
  } catch (err) {
    const responseMessage =
      err && typeof err === 'object' && 'response' in err
        ? (err as any).response?.data?.message
        : undefined
    error.value = responseMessage || '运行失败，请检查参数和网络连接'
  } finally {
    loading.value = false
  }
}

/** 监听测试抽屉的开启，获取开始节点参数列表 */
watch(showTestDrawer, (value) => {
  if (!value) return

  /// 查找start节点
  const startNode = getStartNode()

  // 获取参数定义
  const parameters = startNode.data?.parameters || []
  const paramDefinitions: Record<string, StartNodeParameter> = {}

  // 加入参数选项方便用户添加非必须参数
  parameters.forEach((param: StartNodeParameter) => {
    paramDefinitions[param.name] = param
  })

  function mergeIfRequiredButNotSet(target: WorkflowParam[]) {
    let needPushList: WorkflowParam[] = []
    for (let key in paramDefinitions) {
      let param = paramDefinitions[key]

      if (param.required) {
        let item = target.find((item: WorkflowParam) => item.key === key)

        if (!item) {
          needPushList.push({ key: param.name, value: param.defaultValue || '' })
        }
      }
    }
    target.push(...needPushList)
  }
  // 自动装载需必填的参数
  mergeIfRequiredButNotSet(params4Test.value)

  paramsOfStartNode.value = paramDefinitions
})

/** 获取开始节点 */
const getStartNode = () => {
  const val = tinyflowRef.value.getData()
  const startNode = val.nodes.find((node) => node.type === 'startNode')
  if (!startNode) {
    throw new Error('流程缺少开始节点')
  }
  return startNode
}

/** 添加参数项 */
const addParam = () => {
  params4Test.value.push({ key: '', value: '' })
}

/** 删除参数项 */
const removeParam = (index: number) => {
  params4Test.value.splice(index, 1)
}

/** 类型转换函数 */
const convertParamValue = (value: string, dataType: string) => {
  if (value === '') return null // 空值处理

  switch (dataType) {
    case 'String':
      return String(value)
    case 'Number':
      const num = Number(value)
      if (isNaN(num)) throw new Error('非数字格式')
      return num
    case 'Boolean':
      if (value.toLowerCase() === 'true') return true
      if (value.toLowerCase() === 'false') return false
      throw new Error('必须为 true/false')
    case 'Object':
    case 'Array':
      try {
        return JSON.parse(value)
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e)
        throw new Error(`JSON格式错误: ${message}`)
      }
    default:
      throw new Error(`不支持的类型: ${dataType}`)
  }
}

/** 表单校验 */
const validate = async () => {
  try {
    // 获取最新的流程数据
    if (!workflowData.value) {
      throw new Error('请设计流程')
    }
    workflowData.value = tinyflowRef.value.getData()
    return true
  } catch (error) {
    throw error
  }
}
defineExpose({
  validate
})
</script>

<style lang="css" scoped>
.result-content {
  max-height: 300px;
  padding: 12px;
  overflow: auto;
  font-family: Monaco, Consolas, monospace;
  font-size: 14px;
  line-height: 1.5;
  white-space: pre-wrap;
  background: white;
  border-radius: 4px;
}
</style>
