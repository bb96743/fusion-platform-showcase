package com.fusion.framework.banner.core;

import cn.hutool.core.thread.ThreadUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.util.ClassUtils;

import java.util.concurrent.TimeUnit;

/**
 * 项目启动成功后，提供文档相关的地址
 *
 */
@Slf4j
public class BannerApplicationRunner implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) {
        ThreadUtil.execute(() -> {
            ThreadUtil.sleep(1, TimeUnit.SECONDS); // 延迟 1 秒，保证输出到结尾
            log.info("\n----------------------------------------------------------\n\t" +
                            "项目启动成功！\n\t" +
                            "接口文档: \t{} \n\t" +
                            "开发文档: \t{} \n\t" +
                            "视频教程: \t{} \n" +
                            "----------------------------------------------------------",
                    "https://fusion.example.com/api-doc/",
                    "https://fusion.example.com",
                    "");

            // 工作流
            if (isNotPresent("com.fusion.module.bpm.framework.flowable.config.BpmFlowableConfiguration")) {
                System.out.println("[工作流模块 fusion-module-bpm - 已禁用][参考 https://fusion.example.com/bpm/ 开启]");
            }
            // 支付平台
            if (isNotPresent("com.fusion.module.pay.framework.pay.config.PayConfiguration")) {
                System.out.println("[支付系统 fusion-module-pay - 已禁用][参考 https://fusion.example.com/pay/build/ 开启]");
            }
            // 数据报表
            if (isNotPresent("com.fusion.module.report.framework.security.config.SecurityConfiguration")) {
                System.out.println("[报表模块 fusion-module-report - 已禁用][参考 https://fusion.example.com/report/ 开启]");
            }
            // 微信公众号
            if (isNotPresent("com.fusion.module.mp.framework.mp.config.MpConfiguration")) {
                System.out.println("[微信公众号 fusion-module-mp - 已禁用][参考 https://fusion.example.com/mp/build/ 开启]");
            }
            // 商城系统
            if (isNotPresent("com.fusion.module.trade.framework.web.config.TradeWebConfiguration")) {
                System.out.println("[商城系统 fusion-module-mall - 已禁用][参考 https://fusion.example.com/mall/build/ 开启]");
            }
            // ERP 系统
            if (isNotPresent("com.fusion.module.erp.framework.web.config.ErpWebConfiguration")) {
                System.out.println("[ERP 系统 fusion-module-erp - 已禁用][参考 https://fusion.example.com/erp/build/ 开启]");
            }
            // WMS 仓库管理系统
            if (isNotPresent("com.fusion.module.wms.framework.web.config.WmsWebConfiguration")) {
                System.out.println("[WMS 仓库管理系统 fusion-module-wms - 已禁用][参考 https://fusion.example.com/wms/build/ 开启]");
            }
            // CRM 系统
            if (isNotPresent("com.fusion.module.crm.framework.web.config.CrmWebConfiguration")) {
                System.out.println("[CRM 系统 fusion-module-crm - 已禁用][参考 https://fusion.example.com/crm/build/ 开启]");
            }
            // MES 系统
            if (isNotPresent("com.fusion.module.mes.framework.web.config.MesWebConfiguration")) {
                System.out.println("[MES 系统 fusion-module-mes - 已禁用][参考 https://fusion.example.com/mes/build/ 开启]");
            }
            // HRM 人力资源管理系统
            if (isNotPresent("com.fusion.module.hrm.framework.web.config.HrmWebConfiguration")) {
                System.out.println("[HRM 人力资源管理系统 fusion-module-hrm - 已禁用][参考 https://fusion.example.com/hrm/build/ 开启]");
            }
            // FMS 财务管理系统
            if (isNotPresent("com.fusion.module.fms.framework.web.config.FmsWebConfiguration")) {
                System.out.println("[FMS 财务管理系统 fusion-module-fms - 已禁用][参考 https://fusion.example.com/fms/build/ 开启]");
            }
            // PMS 系统
            if (isNotPresent("com.fusion.module.pms.framework.web.config.PmsWebConfiguration")) {
                System.out.println("[PMS 项目管理系统 fusion-module-pms - 已禁用][参考 https://fusion.example.com/pms/build/ 开启]");
            }
            // OA 办公自动化
            if (isNotPresent("com.fusion.module.oa.framework.config.OaProperties")) {
                System.out.println("[OA 协同办公 fusion-module-oa - 已禁用][参考 https://fusion.example.com/oa/build/ 开启]");
            }
            // AI 大模型
            if (isNotPresent("com.fusion.module.ai.framework.web.config.AiWebConfiguration")) {
                System.out.println("[AI 大模型 fusion-module-ai - 已禁用][参考 https://fusion.example.com/ai/build/ 开启]");
            }
            // IoT 物联网
            if (isNotPresent("com.fusion.module.iot.framework.web.config.IotWebConfiguration")) {
                System.out.println("[IoT 物联网 fusion-module-iot - 已禁用][参考 https://fusion.example.com/iot/build/ 开启]");
            }
            // IM 即时通讯
            if (isNotPresent("com.fusion.module.im.framework.web.config.ImWebConfiguration")) {
                System.out.println("[IM 即时通讯 fusion-module-im - 已禁用][参考 https://fusion.example.com/im/build/ 开启]");
            }
        });
    }

    private static boolean isNotPresent(String className) {
        return !ClassUtils.isPresent(className, ClassUtils.getDefaultClassLoader());
    }

}