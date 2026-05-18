package com.cpms.service;

import com.cpms.entity.ParkingSpot;
import com.cpms.entity.Vehicle;
import com.cpms.repository.ParkingSpotRepository;
import com.cpms.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ParkingService {

    private final ParkingSpotRepository spotRepository;
    private final VehicleRepository vehicleRepository;

    // === 车位管理 ===
    public List<ParkingSpot> listAllSpots() {
        return spotRepository.findAll();
    }

    public List<ParkingSpot> listAvailableSpots() {
        return spotRepository.findByStatus("available");
    }

    public ParkingSpot getSpotById(Long id) {
        return spotRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("停车位不存在"));
    }

    public ParkingSpot createSpot(ParkingSpot spot) {
        return spotRepository.save(spot);
    }

    public ParkingSpot updateSpot(Long id, ParkingSpot updated) {
        ParkingSpot spot = getSpotById(id);
        if (updated.getSpotCode() != null) spot.setSpotCode(updated.getSpotCode());
        if (updated.getLocation() != null) spot.setLocation(updated.getLocation());
        if (updated.getType() != null) spot.setType(updated.getType());
        if (updated.getStatus() != null) spot.setStatus(updated.getStatus());
        return spotRepository.save(spot);
    }

    public void deleteSpot(Long id) {
        spotRepository.deleteById(id);
    }

    // === 车辆管理 ===
    public List<Vehicle> listAllVehicles() {
        return vehicleRepository.findAll();
    }

    public List<Vehicle> listVehiclesByOwner(Long ownerId) {
        return vehicleRepository.findByOwner_OwnerId(ownerId);
    }

    public Vehicle getVehicleById(Long id) {
        return vehicleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("车辆不存在"));
    }

    public Vehicle createVehicle(Vehicle vehicle) {
        if (vehicleRepository.existsByPlateNumber(vehicle.getPlateNumber())) {
            throw new RuntimeException("该车牌号已登记");
        }
        if (vehicle.getSpot() != null && vehicle.getSpot().getSpotId() != null) {
            ParkingSpot spot = getSpotById(vehicle.getSpot().getSpotId());
            if ("occupied".equals(spot.getStatus())) {
                throw new RuntimeException("该车位已被占用");
            }
            vehicle.setSpot(spot);
            spot.setStatus("occupied");
            spotRepository.save(spot);
        }
        return vehicleRepository.save(vehicle);
    }

    public Vehicle updateVehicle(Long id, Vehicle updated) {
        Vehicle vehicle = getVehicleById(id);
        if (updated.getPlateNumber() != null) vehicle.setPlateNumber(updated.getPlateNumber());
        if (updated.getVehicleType() != null) vehicle.setVehicleType(updated.getVehicleType());
        if (updated.getColor() != null) vehicle.setColor(updated.getColor());
        return vehicleRepository.save(vehicle);
    }

    public void deleteVehicle(Long id) {
        Vehicle vehicle = getVehicleById(id);
        if (vehicle.getSpot() != null) {
            ParkingSpot spot = vehicle.getSpot();
            spot.setStatus("available");
            spotRepository.save(spot);
        }
        vehicleRepository.deleteById(id);
    }
}
