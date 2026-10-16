<script lang="ts" setup>
import * as ConfigApi from '@/api/infra/config'
import { UploadImg } from '@/components/UploadFile'
import { reloadLogo } from '@/hooks/web/useLogoUrl'

/**
 * 「项目配置」抽屉 → 项目 Logo 上传
 *
 * 为什么放在这里而不是一个独立菜单页：
 *   侧边栏/登录页的 Logo 属于**品牌外观**，与主题色、布局同属「项目配置」抽屉的范畴；
 *   单开一个后台菜单会让它跟业务功能混在一起，也不好找。
 *
 * 为什么只有一个上传槽、没有亮/暗开关：
 *   内置图是「品牌渐变圆角方盒 + **实心白色**四角火花」。方盒不透明，自身与深色侧边栏
 *   (#001529) 和白底都有足够反差，**同一张图直接用在两种背景上即可**，故不需要分版本。
 *   （曾经做过亮/暗两版 + 手选开关，但"亮/暗"存在真实歧义——指图标底色还是指背景色？
 *    且两版素材与迁移的维护成本明显高于收益，项目负责人决定固定单一版本，已移除。）
 *
 * 读的是免登录接口 `getLogoUrl()`，写的是带权限的 `updateLogoUrl()`。
 * 保存/恢复成功后调用 `reloadLogo()`，侧边栏与登录页**无需刷新页面**即可换图。
 */
defineOptions({ name: 'ProjectLogo' })

const { t } = useI18n()
const message = useMessage()

const logoUrl = ref('')
/** 已保存的值：用于判断「恢复内置图片」是否可用 */
const savedUrl = ref('')
const loading = ref(true)
const saving = ref(false)

const load = async () => {
  loading.value = true
  try {
    const url = (await ConfigApi.getLogoUrl()) as unknown as string
    logoUrl.value = url || ''
    savedUrl.value = logoUrl.value
  } catch {
    message.error(t('setting.projectLogoLoadFailed'))
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  saving.value = true
  try {
    await ConfigApi.updateLogoUrl(logoUrl.value)
    savedUrl.value = logoUrl.value
    await reloadLogo()
    message.success(t('setting.projectLogoUpdated'))
  } finally {
    saving.value = false
  }
}

const handleReset = async () => {
  saving.value = true
  try {
    // 传空串：后端清空配置值，前端回退到内置 logo.png
    await ConfigApi.updateLogoUrl('')
    logoUrl.value = ''
    savedUrl.value = ''
    await reloadLogo()
    message.success(t('setting.projectLogoResetDone'))
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<template>
  <div v-loading="loading" class="flex flex-col items-center">
    <UploadImg v-model="logoUrl" :limit="1" height="110px" width="110px" />
    <div class="mt-6px text-12px leading-5 text-gray-500">
      {{ t('setting.projectLogoDesc') }}
    </div>
    <div class="mt-10px flex items-center gap-8px">
      <ElButton type="primary" size="small" :loading="saving" @click="handleSave">
        {{ t('common.save') }}
      </ElButton>
      <ElButton size="small" :loading="saving" :disabled="!savedUrl" @click="handleReset">
        {{ t('setting.projectLogoReset') }}
      </ElButton>
    </div>
  </div>
</template>
