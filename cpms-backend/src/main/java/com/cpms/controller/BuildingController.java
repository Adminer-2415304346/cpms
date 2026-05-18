package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Building;
import com.cpms.service.BuildingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/buildings")
@RequiredArgsConstructor
public class BuildingController {

    private final BuildingService buildingService;

    @GetMapping
    public ApiResult<List<Building>> list() {
        return ApiResult.success(buildingService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Building> getById(@PathVariable Long id) {
        return ApiResult.success(buildingService.getById(id));
    }

    @PostMapping
    public ApiResult<Building> create(@RequestBody Building building) {
        return ApiResult.success(buildingService.create(building));
    }

    @PutMapping("/{id}")
    public ApiResult<Building> update(@PathVariable Long id, @RequestBody Building building) {
        return ApiResult.success(buildingService.update(id, building));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        buildingService.delete(id);
        return ApiResult.success();
    }
}
