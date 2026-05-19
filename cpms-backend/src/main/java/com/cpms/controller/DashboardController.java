package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.dto.DashboardStats;
import com.cpms.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public ApiResult<DashboardStats> stats() {
        return ApiResult.success(dashboardService.getStats());
    }
}
