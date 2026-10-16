# 第三方声明 / Third-Party Notices

本项目（Fusion）的代码基座来自以下开源项目的二次开发。依据 MIT 许可证的要求，
在此保留原始版权声明与许可声明。

## 1. 后端基座

- 项目：ruoyi-vue-pro（芋道源码）
- 许可证：MIT
- 原始版权声明：`Copyright (c) 2021 ruoyi-vue-pro`
- 完整许可原文：见本目录下的 [`LICENSE`](./LICENSE)

## 2. 前端基座

- 项目：yudao-ui-admin-vue3
- 许可证：MIT
- 原始版权声明：`Copyright (c) 2021-present Archer`
- 该前端项目本身基于 `vue-element-plus-admin` 模板演进
- 完整许可原文：见前端工程目录下的 `LICENSE`

## 3. 关于本项目自身的改动

本项目在上述基座之上进行了以下改动：

- 移除了未使用的业务模块与演示代码；
- 替换了项目名称、包名、模块前缀、配置前缀、图标与界面文案；
- 移除了上游作者的个人信息、推广内容与外部仓库链接；
- 升级技术底座至 Spring Boot 4.1.1 + Java 21，并启用 Spring AI 2.0。

这些改动不改变上述第三方组件的许可条件。

## 4. 第三方依赖

本项目还依赖大量第三方开源库（Spring Boot、MyBatis-Plus、Druid、Redisson、Flowable、
积木报表、WxJava、JustAuth 等），各自的许可证以其发布方声明为准。
**若本项目对外分发或商用，建议单独执行一次依赖许可证扫描**，
特别关注 Flowable、积木报表（JimuReport）等具有独立授权条件的组件。

### 已移除的 GPL/双授权依赖

上游前端曾引入 `dhtmlx-gantt`（GPL-2.0 或商业双授权），仅用于 MES / PMS 模块的甘特图。
本项目中这两个模块已被移除，该依赖不再存在。
