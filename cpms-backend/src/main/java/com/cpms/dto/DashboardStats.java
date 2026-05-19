package com.cpms.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class DashboardStats {
    private long buildings;
    private long owners;
    private long pendingRepairs;
    private long announcements;
}
