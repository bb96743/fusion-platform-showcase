package com.fusion.module.infra.controller.admin.config;

import cn.hutool.core.util.StrUtil;
import com.fusion.framework.apilog.core.annotation.ApiAccessLog;
import com.fusion.framework.common.pojo.CommonResult;
import com.fusion.framework.common.pojo.PageParam;
import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.excel.core.util.ExcelUtils;
import com.fusion.module.infra.controller.admin.config.vo.ConfigPageReqVO;
import com.fusion.module.infra.controller.admin.config.vo.ConfigRespVO;
import com.fusion.module.infra.controller.admin.config.vo.ConfigSaveReqVO;
import com.fusion.module.infra.convert.config.ConfigConvert;
import com.fusion.module.infra.dal.dataobject.config.ConfigDO;
import com.fusion.module.infra.enums.ErrorCodeConstants;
import com.fusion.module.infra.service.config.ConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.annotation.security.PermitAll;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

import static com.fusion.framework.apilog.core.enums.OperateTypeEnum.EXPORT;
import static com.fusion.framework.common.exception.util.ServiceExceptionUtil.exception;
import static com.fusion.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 参数配置")
@RestController
@RequestMapping("/infra/config")
@Validated
public class ConfigController {

    /**
     * 项目 Logo 的配置键 —— 存的是上传后的图片 URL（侧边栏与登录页共用）
     */
    public static final String CONFIG_KEY_LOGO = "system.logo";

    @Resource
    private ConfigService configService;

    @PostMapping("/create")
    @Operation(summary = "创建参数配置")
    @PreAuthorize("@ss.hasPermission('infra:config:create')")
    public CommonResult<Long> createConfig(@Valid @RequestBody ConfigSaveReqVO createReqVO) {
        return success(configService.createConfig(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "修改参数配置")
    @PreAuthorize("@ss.hasPermission('infra:config:update')")
    public CommonResult<Boolean> updateConfig(@Valid @RequestBody ConfigSaveReqVO updateReqVO) {
        configService.updateConfig(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除参数配置")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('infra:config:delete')")
    public CommonResult<Boolean> deleteConfig(@RequestParam("id") Long id) {
        configService.deleteConfig(id);
        return success(true);
    }

    @DeleteMapping("/delete-list")
    @Operation(summary = "批量删除参数配置")
    @Parameter(name = "ids", description = "编号列表", required = true)
    @PreAuthorize("@ss.hasPermission('infra:config:delete')")
    public CommonResult<Boolean> deleteConfigList(@RequestParam("ids") List<Long> ids) {
        configService.deleteConfigList(ids);
        return success(true);
    }

    @GetMapping(value = "/get")
    @Operation(summary = "获得参数配置")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('infra:config:query')")
    public CommonResult<ConfigRespVO> getConfig(@RequestParam("id") Long id) {
        return success(ConfigConvert.INSTANCE.convert(configService.getConfig(id)));
    }

    @GetMapping(value = "/get-value-by-key")
    @Operation(summary = "根据参数键名查询参数值", description = "不可见的配置，不允许返回给前端")
    @Parameter(name = "key", description = "参数键", required = true, example = "yunai.biz.username")
    public CommonResult<String> getConfigKey(@RequestParam("key") String key) {
        ConfigDO config = configService.getConfigByKey(key);
        if (config == null) {
            return success(null);
        }
        if (!config.getVisible()) {
            throw exception(ErrorCodeConstants.CONFIG_GET_VALUE_ERROR_IF_VISIBLE);
        }
        return success(config.getValue());
    }

    /**
     * 获得项目 Logo 的访问地址（无需登录）。
     *
     * 为什么单独开一个公开接口，而不是把 {@code /get-value-by-key} 公开：
     * 后者按**任意 key** 查，一旦免鉴权就会把 {@code system.user.init-password} 这类敏感配置
     * 泄露给未登录用户。这里**硬编码只读 {@link #CONFIG_KEY_LOGO}**，不接收外部 key，所以没有泄露风险。
     *
     * 用途：登录页（未登录）与侧边栏都要拿这个 URL；值为空时前端回退到静态 {@code logo.png}。
     *
     * 为什么只有一个值、没有亮/暗模式：
     * 内置图是「品牌渐变圆角方盒 + 实心白色四角火花」，方盒不透明，
     * 自身与深色侧边栏(#001529)和白底都有足够反差，同一张图可直接用在两种背景上。
     * （曾实现过亮/暗双版本 + 手选开关，但"亮/暗"存在真实歧义且维护成本高于收益，已移除。）
     */
    @GetMapping(value = "/get-logo")
    @Operation(summary = "获得项目 Logo（无需登录）")
    @PermitAll
    public CommonResult<String> getLogo() {
        ConfigDO config = configService.getConfigByKey(CONFIG_KEY_LOGO);
        return success(config != null ? StrUtil.blankToDefault(config.getValue(), "") : "");
    }

    /**
     * 更新项目 Logo 的地址
     *
     * @param url 图片地址；**留空表示恢复为内置图片**
     */
    @PutMapping(value = "/update-logo")
    @Operation(summary = "更新项目 Logo")
    @Parameter(name = "url", description = "图片地址；留空表示恢复内置图片")
    @PreAuthorize("@ss.hasPermission('infra:config:update')")
    public CommonResult<Boolean> updateLogo(@RequestParam(value = "url", required = false) String url) {
        ConfigDO config = configService.getConfigByKey(CONFIG_KEY_LOGO);
        if (config == null) {
            throw exception(ErrorCodeConstants.CONFIG_NOT_EXISTS);
        }
        // 走「允许空值」的专用方法：通用 updateConfig 的 VO 上 value 带 @NotBlank，无法清空
        configService.updateConfigValue(config.getId(), StrUtil.blankToDefault(url, ""));
        return success(true);
    }

    @GetMapping("/page")
    @Operation(summary = "获取参数配置分页")
    @PreAuthorize("@ss.hasPermission('infra:config:query')")
    public CommonResult<PageResult<ConfigRespVO>> getConfigPage(@Valid ConfigPageReqVO pageReqVO) {
        PageResult<ConfigDO> page = configService.getConfigPage(pageReqVO);
        return success(ConfigConvert.INSTANCE.convertPage(page));
    }

    @GetMapping("/export-excel")
    @Operation(summary = "导出参数配置")
    @PreAuthorize("@ss.hasPermission('infra:config:export')")
    @ApiAccessLog(operateType = EXPORT)
    public void exportConfig(ConfigPageReqVO exportReqVO,
                             HttpServletResponse response) throws IOException {
        exportReqVO.setPageSize(PageParam.PAGE_SIZE_NONE);
        List<ConfigDO> list = configService.getConfigPage(exportReqVO).getList();
        // 输出
        ExcelUtils.write(response, "参数配置.xls", "数据", ConfigRespVO.class,
                ConfigConvert.INSTANCE.convertList(list));
    }

}
