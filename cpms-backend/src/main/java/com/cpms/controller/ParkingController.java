package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.ParkingSpot;
import com.cpms.entity.Vehicle;
import com.cpms.service.ParkingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/parking")
@RequiredArgsConstructor
public class ParkingController {

    private final ParkingService parkingService;

    // === 车位 ===
    @GetMapping("/spots")
    public ApiResult<List<ParkingSpot>> listSpots(@RequestParam(required = false) boolean available) {
        if (available) return ApiResult.success(parkingService.listAvailableSpots());
        return ApiResult.success(parkingService.listAllSpots());
    }

    @GetMapping("/spots/{id}")
    public ApiResult<ParkingSpot> getSpot(@PathVariable Long id) {
        return ApiResult.success(parkingService.getSpotById(id));
    }

    @PostMapping("/spots")
    public ApiResult<ParkingSpot> createSpot(@RequestBody ParkingSpot spot) {
        return ApiResult.success(parkingService.createSpot(spot));
    }

    @PutMapping("/spots/{id}")
    public ApiResult<ParkingSpot> updateSpot(@PathVariable Long id, @RequestBody ParkingSpot spot) {
        return ApiResult.success(parkingService.updateSpot(id, spot));
    }

    @DeleteMapping("/spots/{id}")
    public ApiResult<Void> deleteSpot(@PathVariable Long id) {
        parkingService.deleteSpot(id);
        return ApiResult.success();
    }

    // === 车辆 ===
    @GetMapping("/vehicles")
    public ApiResult<List<Vehicle>> listVehicles(@RequestParam(required = false) Long ownerId) {
        if (ownerId != null) return ApiResult.success(parkingService.listVehiclesByOwner(ownerId));
        return ApiResult.success(parkingService.listAllVehicles());
    }

    @GetMapping("/vehicles/{id}")
    public ApiResult<Vehicle> getVehicle(@PathVariable Long id) {
        return ApiResult.success(parkingService.getVehicleById(id));
    }

    @PostMapping("/vehicles")
    public ApiResult<Vehicle> createVehicle(@RequestBody Vehicle vehicle) {
        return ApiResult.success(parkingService.createVehicle(vehicle));
    }

    @PutMapping("/vehicles/{id}")
    public ApiResult<Vehicle> updateVehicle(@PathVariable Long id, @RequestBody Vehicle vehicle) {
        return ApiResult.success(parkingService.updateVehicle(id, vehicle));
    }

    @DeleteMapping("/vehicles/{id}")
    public ApiResult<Void> deleteVehicle(@PathVariable Long id) {
        parkingService.deleteVehicle(id);
        return ApiResult.success();
    }
}
