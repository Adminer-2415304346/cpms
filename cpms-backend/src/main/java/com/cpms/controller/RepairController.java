package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Repair;
import com.cpms.service.RepairService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/repairs")
@RequiredArgsConstructor
public class RepairController {

    private final RepairService repairService;

    @GetMapping
    public ApiResult<List<Repair>> list(@RequestParam(required = false) Long ownerId,
                                        @RequestParam(required = false) String status,
                                        @RequestParam(required = false) Long staffId) {
        if (ownerId != null) return ApiResult.success(repairService.listByOwner(ownerId));
        if (status != null) return ApiResult.success(repairService.listByStatus(status));
        if (staffId != null) return ApiResult.success(repairService.listByStaff(staffId));
        return ApiResult.success(repairService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Repair> getById(@PathVariable Long id) {
        return ApiResult.success(repairService.getById(id));
    }

    @PostMapping
    public ApiResult<Repair> create(@RequestBody Repair repair) {
        return ApiResult.success(repairService.create(repair));
    }

    @PutMapping("/{id}/assign")
    public ApiResult<Repair> assign(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        return ApiResult.success(repairService.assign(id, body.get("staffId")));
    }

    @PutMapping("/{id}/start")
    public ApiResult<Repair> startWork(@PathVariable Long id) {
        return ApiResult.success(repairService.startWork(id));
    }

    @PutMapping("/{id}/complete")
    public ApiResult<Repair> complete(@PathVariable Long id) {
        return ApiResult.success(repairService.complete(id));
    }

    @PutMapping("/{id}/confirm")
    public ApiResult<Repair> confirm(@PathVariable Long id) {
        return ApiResult.success(repairService.confirm(id));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        repairService.delete(id);
        return ApiResult.success();
    }
}
