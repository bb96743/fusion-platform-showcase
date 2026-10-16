<!--
  首页 / 工作台

  ⚠️ 说明：本页原为上游的演示看板，其中的「项目列表」「通知公告」「快捷入口」全部是
  **硬编码的假数据**，且包含指向原作者仓库的外链与已删除模块的路由。
  改造时已整体替换为本页 —— 只保留欢迎卡片与一段静态的入门提示，
  不包含任何假数据、外链或死路由。

  后续请按本项目实际业务替换为真实看板（例如接入统计接口、待办、图表示例）。
-->
<template>
  <div>
    <el-card shadow="never">
      <div class="flex items-center">
        <el-avatar :src="avatar" :size="70" class="mr-16px">
          <img src="@/assets/imgs/avatar.gif" alt="" />
        </el-avatar>
        <div>
          <div class="text-20px">
            {{ t('workplace.welcome') }} {{ username }} {{ t('workplace.happyDay') }}
          </div>
          <div class="mt-10px text-14px text-gray-500">{{ t('workplace.toady') }}</div>
        </div>
      </div>
    </el-card>

    <el-row class="mt-8px" :gutter="8">
      <el-col :span="24">
        <el-card shadow="never" class="mb-8px">
          <template #header>
            <div class="flex items-center justify-between">
              <span class="font-bold">开始使用</span>
            </div>
          </template>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="系统管理">
              用户、角色、菜单权限、部门、岗位、字典、租户等基础能力
            </el-descriptions-item>
            <el-descriptions-item label="基础设施">
              代码生成器、文件存储、参数配置、定时任务、日志查询
            </el-descriptions-item>
            <el-descriptions-item label="工作流">
              流程模型设计、表单设计、任务审批（Flowable）
            </el-descriptions-item>
            <el-descriptions-item label="报表大屏"> 报表设计器与大屏设计器 </el-descriptions-item>
            <el-descriptions-item label="AI 能力">
              对话、知识库、绘图、写作（Spring AI）
            </el-descriptions-item>
          </el-descriptions>
          <div class="mt-12px text-13px text-gray-400">
            提示：左侧菜单由后端「系统管理 → 菜单管理」下发，按角色权限动态生成。
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script lang="ts" setup>
import { useUserStore } from '@/store/modules/user'

// 路由与后端菜单通过 component_name 匹配，名称需保持为 Index
defineOptions({ name: 'Index' })

const { t } = useI18n()
const userStore = useUserStore()
const avatar = userStore.getUser.avatar
const username = userStore.getUser.nickname
</script>
