package com.fusion.server.controller;

import com.fusion.framework.common.pojo.CommonResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static com.fusion.framework.common.exception.enums.GlobalErrorCodeConstants.NOT_IMPLEMENTED;

/**
 * 默认 Controller，解决部分 module 未开启时的 404 提示。
 *
 * <p>本项目按模块逐步启用（计划见 {@code 需求分析文档.md} 第 14 章），本类为
 * <b>尚未启用</b>的模块提供可读的错误提示，而不是让前端收到生硬的 404。
 *
 * <p>维护约定：
 * <ul>
 *   <li>某个模块<b>启用后必须删掉这里对应的桩方法</b> —— 否则该模块下不存在的路径
 *       会命中桩方法并返回「已禁用」，与事实矛盾（本项目 bpm / report / ai 曾出现
 *       这种「模块已启用、却还挂着已禁用提示」的自相矛盾状态）。</li>
 *   <li>当前已启用：<b>system / infra / bpm / report / ai</b>，故这五个模块没有桩方法。</li>
 * </ul>
 *
 * <p>历史说明：原先这里还有一个 {@code /test} 接口（{@code @PermitAll}，把请求的
 * query / header / body 全部打进日志）。它属于上游的调试接口，存在信息泄露风险，
 * 已在 F0 阶段删除。
 */
@RestController
public class DefaultController {

    @RequestMapping(value = { "/admin-api/pay/**"})
    public CommonResult<Boolean> pay404() {
        return notEnabled("支付", "fusion-module-pay");
    }

    @RequestMapping("/admin-api/mp/**")
    public CommonResult<Boolean> mp404() {
        return notEnabled("微信公众号", "fusion-module-mp");
    }

    @RequestMapping(value = { "/admin-api/product/**", // 商品中心
            "/admin-api/trade/**", // 交易中心
            "/admin-api/promotion/**" }) // 营销中心
    public CommonResult<Boolean> mall404() {
        return notEnabled("商城系统", "fusion-module-mall");
    }

    @RequestMapping("/admin-api/erp/**")
    public CommonResult<Boolean> erp404() {
        return notEnabled("ERP", "fusion-module-erp");
    }

    @RequestMapping(value = { "/admin-api/wms/**"})
    public CommonResult<Boolean> wms404() {
        return notEnabled("WMS 仓库管理", "fusion-module-wms");
    }

    @RequestMapping("/admin-api/crm/**")
    public CommonResult<Boolean> crm404() {
        return notEnabled("CRM", "fusion-module-crm");
    }

    @RequestMapping(value = { "/admin-api/mes/**"})
    public CommonResult<Boolean> mes404() {
        return notEnabled("MES", "fusion-module-mes");
    }

    @RequestMapping("/admin-api/hrm/**")
    public CommonResult<Boolean> hrm404() {
        return notEnabled("HRM 人力资源", "fusion-module-hrm");
    }

    @RequestMapping("/admin-api/fms/**")
    public CommonResult<Boolean> fms404() {
        return notEnabled("FMS 财务管理", "fusion-module-fms");
    }

    @RequestMapping("/admin-api/pms/**")
    public CommonResult<Boolean> pms404() {
        return notEnabled("PMS 项目管理", "fusion-module-pms");
    }

    @RequestMapping("/admin-api/oa/**")
    public CommonResult<Boolean> oa404() {
        return notEnabled("OA 协同办公", "fusion-module-oa");
    }

    @RequestMapping(value = { "/admin-api/iot/**"})
    public CommonResult<Boolean> iot404() {
        return notEnabled("IoT 物联网", "fusion-module-iot");
    }

    @RequestMapping(value = { "/admin-api/im/**"})
    public CommonResult<Boolean> im404() {
        return notEnabled("IM 即时通讯", "fusion-module-im");
    }

    /**
     * 统一的「模块未启用」响应。
     *
     * <p>刻意**不再拼接文档地址**：上游此处写的是作者的文档站，品牌替换后变成了
     * 一个并不存在的 {@code fusion.example.com} 假地址 —— 比不给链接更糟。
     * 需要查阅说明时请看仓库根目录的 {@code README.md} 与 {@code 需求分析文档.md}。
     */
    private CommonResult<Boolean> notEnabled(String moduleName, String moduleArtifact) {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[" + moduleName + "模块 " + moduleArtifact + " - 已禁用] 本项目尚未启用该模块");
    }

}
