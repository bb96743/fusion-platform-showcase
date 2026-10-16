package com.fusion.module.pay.convert.wallet;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.module.pay.controller.admin.wallet.vo.wallet.PayWalletRespVO;
import com.fusion.module.pay.controller.app.wallet.vo.wallet.AppPayWalletRespVO;
import com.fusion.module.pay.dal.dataobject.wallet.PayWalletDO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper
public interface PayWalletConvert {

    PayWalletConvert INSTANCE = Mappers.getMapper(PayWalletConvert.class);

    AppPayWalletRespVO convert(PayWalletDO bean);

    PayWalletRespVO convert02(PayWalletDO bean);

    PageResult<PayWalletRespVO> convertPage(PageResult<PayWalletDO> page);

}
