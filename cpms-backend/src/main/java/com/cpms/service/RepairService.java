package com.cpms.service;

import com.cpms.entity.Repair;
import com.cpms.repository.RepairRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RepairService {

    private final RepairRepository repairRepository;

    public List<Repair> listAll() {
        return repairRepository.findAll();
    }

    public List<Repair> listByOwner(Long ownerId) {
        return repairRepository.findByOwner_OwnerId(ownerId);
    }

    public List<Repair> listByStatus(String status) {
        return repairRepository.findByStatus(status);
    }

    public List<Repair> listByStaff(Long staffId) {
        return repairRepository.findByStaff_UserId(staffId);
    }

    public Repair getById(Long id) {
        return repairRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("报修工单不存在"));
    }

    public Repair create(Repair repair) {
        return repairRepository.save(repair);
    }

    public Repair assign(Long id, Long staffId) {
        Repair repair = getById(id);
        if (!"pending".equals(repair.getStatus())) {
            throw new RuntimeException("只有待处理的工单才能派工");
        }
        com.cpms.entity.User staff = new com.cpms.entity.User();
        staff.setUserId(staffId);
        repair.setStaff(staff);
        repair.setStatus("assigned");
        return repairRepository.save(repair);
    }

    public Repair startWork(Long id) {
        Repair repair = getById(id);
        if (!"assigned".equals(repair.getStatus())) {
            throw new RuntimeException("只有已派工的工单才能开始处理");
        }
        repair.setStatus("in_progress");
        return repairRepository.save(repair);
    }

    public Repair complete(Long id) {
        Repair repair = getById(id);
        if (!"in_progress".equals(repair.getStatus())) {
            throw new RuntimeException("只有处理中的工单才能标记完成");
        }
        repair.setStatus("completed");
        repair.setCompletedAt(LocalDateTime.now());
        return repairRepository.save(repair);
    }

    public Repair confirm(Long id) {
        Repair repair = getById(id);
        if (!"completed".equals(repair.getStatus())) {
            throw new RuntimeException("只有已完成的工单才能确认");
        }
        repair.setStatus("confirmed");
        return repairRepository.save(repair);
    }

    public void delete(Long id) {
        repairRepository.deleteById(id);
    }
}
