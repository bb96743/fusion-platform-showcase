package com.fusion.module.system.service.logger;

import com.fusion.framework.common.pojo.PageResult;
import com.fusion.framework.common.util.object.BeanUtils;
import com.fusion.framework.common.biz.system.logger.dto.OperateLogCreateReqDTO;
import com.fusion.module.system.api.logger.dto.OperateLogPageReqDTO;
import com.fusion.module.system.controller.admin.logger.vo.operatelog.OperateLogPageReqVO;
import com.fusion.module.system.dal.dataobject.logger.OperateLogDO;
import com.fusion.module.system.dal.mysql.logger.OperateLogMapper;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;

/**
 * 操作日志 Service 实现类
 *
 */
@Service
@Validated
@Slf4j
public class OperateLogServiceImpl implements OperateLogService {

    @Resource
    private OperateLogMapper operateLogMapper;

    @Override
    public void createOperateLog(OperateLogCreateReqDTO createReqDTO) {
        OperateLogDO log = BeanUtils.toBean(createReqDTO, OperateLogDO.class);
        operateLogMapper.insert(log);
    }

    @Override
    public OperateLogDO getOperateLog(Long id) {
        return operateLogMapper.selectById(id);
    }

    @Override
    public PageResult<OperateLogDO> getOperateLogPage(OperateLogPageReqVO pageReqVO) {
        return operateLogMapper.selectPage(pageReqVO);
    }

    @Override
    public PageResult<OperateLogDO> getOperateLogPage(OperateLogPageReqDTO pageReqDTO) {
        return operateLogMapper.selectPage(pageReqDTO);
    }

    @Override
    @SuppressWarnings("DuplicatedCode")
    public Integer cleanOperateLog(Integer exceedDay, Integer deleteLimit) {
        int count = 0;
        LocalDateTime expireDate = LocalDateTime.now().minusDays(exceedDay);
        for (int i = 0; i < Short.MAX_VALUE; i++) {
            int deleteCount = operateLogMapper.deleteByCreateTimeLt(expireDate, deleteLimit);
            count += deleteCount;
            if (deleteCount < deleteLimit) {
                break;
            }
        }
        return count;
    }
}
