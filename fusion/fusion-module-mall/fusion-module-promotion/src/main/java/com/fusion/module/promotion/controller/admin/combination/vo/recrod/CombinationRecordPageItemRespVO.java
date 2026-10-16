package com.fusion.module.promotion.controller.admin.combination.vo.recrod;

import com.fusion.module.promotion.controller.admin.combination.vo.activity.CombinationActivityRespVO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "管理后台 - 拼团记录的分页项 Response VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class CombinationRecordPageItemRespVO extends CombinationRecordBaseVO {

    @Schema(description = "团长昵称", example = "Fusion 数智业务中台源码")
    private String headNickname;

    // ========== 活动相关 ==========

    private CombinationActivityRespVO activity;

}
