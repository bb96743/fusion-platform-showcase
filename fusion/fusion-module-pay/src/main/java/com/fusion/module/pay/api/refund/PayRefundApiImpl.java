package com.fusion.module.pay.api.refund;

import com.fusion.framework.common.util.object.BeanUtils;
import com.fusion.module.pay.api.refund.dto.PayRefundCreateReqDTO;
import com.fusion.module.pay.api.refund.dto.PayRefundRespDTO;
import com.fusion.module.pay.dal.dataobject.refund.PayRefundDO;
import com.fusion.module.pay.service.refund.PayRefundService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

/**
 * 退款单 API 实现类
 *
 */
@Service
@Validated
public class PayRefundApiImpl implements PayRefundApi {

    @Resource
    private PayRefundService payRefundService;

    @Override
    public Long createRefund(PayRefundCreateReqDTO reqDTO) {
        return payRefundService.createRefund(reqDTO);
    }

    @Override
    public PayRefundRespDTO getRefund(Long id) {
        PayRefundDO refund = payRefundService.getRefund(id);
        return BeanUtils.toBean(refund, PayRefundRespDTO.class);
    }

}
