package com.fusion.module.infra.service.config;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.module.infra.controller.admin.config.vo.ConfigPageReqVO;
import com.fusion.module.infra.controller.admin.config.vo.ConfigSaveReqVO;
import com.fusion.module.infra.dal.dataobject.config.ConfigDO;
import jakarta.validation.Valid;

import java.util.List;

/**
 * 参数配置 Service 接口
 *
 */
public interface ConfigService {

    /**
     * 创建参数配置
     *
     * @param createReqVO 创建信息
     * @return 配置编号
     */
    Long createConfig(@Valid ConfigSaveReqVO createReqVO);

    /**
     * 更新参数配置
     *
     * @param updateReqVO 更新信息
     */
    void updateConfig(@Valid ConfigSaveReqVO updateReqVO);

    /**
     * 直接更新配置项的值（**允许空值**）
     *
     * 为什么不复用 {@link #updateConfig}：它的入参 {@code ConfigSaveReqVO.value} 带 {@code @NotBlank}，
     * 且 `@Valid` 挂在**接口参数**上（配合实现类上的 `@Validated`），所以连内部调用也会被校验，
     * 无法把值清空。而「项目 Logo」需要允许清空以回退到内置图片，故单独提供本方法。
     *
     * @param id    配置编号
     * @param value 新的值（允许空字符串）
     */
    void updateConfigValue(Long id, String value);

    /**
     * 删除参数配置
     *
     * @param id 配置编号
     */
    void deleteConfig(Long id);

    /**
     * 批量删除参数配置
     *
     * @param ids 配置编号列表
     */
    void deleteConfigList(List<Long> ids);

    /**
     * 获得参数配置
     *
     * @param id 配置编号
     * @return 参数配置
     */
    ConfigDO getConfig(Long id);

    /**
     * 根据参数键，获得参数配置
     *
     * @param key 配置键
     * @return 参数配置
     */
    ConfigDO getConfigByKey(String key);

    /**
     * 获得参数配置分页列表
     *
     * @param reqVO 分页条件
     * @return 分页列表
     */
    PageResult<ConfigDO> getConfigPage(ConfigPageReqVO reqVO);

}
