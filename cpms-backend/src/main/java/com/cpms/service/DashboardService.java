package com.cpms.service;

import com.cpms.dto.DashboardStats;
import com.cpms.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final BuildingRepository buildingRepo;
    private final OwnerRepository ownerRepo;
    private final RepairRepository repairRepo;
    private final AnnouncementRepository announcementRepo;

    public DashboardStats getStats() {
        long buildings = buildingRepo.count();
        long owners = ownerRepo.count();
        long pendingRepairs = repairRepo.countByStatusIn(List.of("pending", "assigned", "in_progress"));
        long announcements = announcementRepo.count();
        return new DashboardStats(buildings, owners, pendingRepairs, announcements);
    }
}
