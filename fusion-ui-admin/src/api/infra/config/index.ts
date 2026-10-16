import request from '@/config/axios'

export interface ConfigVO {
  id: number | undefined
  category: string
  name: string
  key: string
  value: string
  type: number
  visible: boolean
  remark: string
  createTime: Date
}

// 查询参数列表
export const getConfigPage = (params: PageParam) => {
  return request.get({ url: '/infra/config/page', params })
}

// 查询参数详情
export const getConfig = (id: number) => {
  return request.get({ url: '/infra/config/get?id=' + id })
}

// 根据参数键名查询参数值
export const getConfigKey = (configKey: string) => {
  return request.get({ url: '/infra/config/get-value-by-key?key=' + configKey })
}

/**
 * 获得项目 Logo 的访问地址
 *
 * 注意：这是**免登录**接口（后端 `@PermitAll`），因为登录页未登录时就要显示 Logo。
 * 后端只返回 `system.logo` 这一个配置的值，不接收外部 key。
 * 返回空字符串表示尚未上传，调用方应回退到内置图片。
 */
export const getLogoUrl = () => {
  return request.get({ url: '/infra/config/get-logo' })
}

/**
 * 更新项目 Logo 的地址
 *
 * @param url 图片地址；传空字符串表示**恢复为内置图片**
 */
export const updateLogoUrl = (url: string) => {
  return request.put({ url: '/infra/config/update-logo?url=' + encodeURIComponent(url || '') })
}

// 新增参数
export const createConfig = (data: ConfigVO) => {
  return request.post({ url: '/infra/config/create', data })
}

// 修改参数
export const updateConfig = (data: ConfigVO) => {
  return request.put({ url: '/infra/config/update', data })
}

// 删除参数
export const deleteConfig = (id: number) => {
  return request.delete({ url: '/infra/config/delete?id=' + id })
}

// 批量删除参数
export const deleteConfigList = (ids: number[]) => {
  return request.delete({ url: '/infra/config/delete-list', params: { ids: ids.join(',') } })
}

// 导出参数
export const exportConfig = (params) => {
  return request.download({ url: '/infra/config/export-excel', params })
}
