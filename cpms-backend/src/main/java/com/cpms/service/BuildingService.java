package com.cpms.service;

import com.cpms.entity.Building;
import com.cpms.repository.BuildingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BuildingService {

    private final BuildingRepository buildingRepository;

    public List<Building> listAll() {
        return buildingRepository.findAll();
    }

    public Building getById(Long id) {
        return buildingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("楼栋不存在"));
    }

    public Building create(Building building) {
        return buildingRepository.save(building);
    }

    public Building update(Long id, Building updated) {
        Building building = getById(id);
        if (updated.getBuildingName() != null) building.setBuildingName(updated.getBuildingName());
        if (updated.getFloors() != null) building.setFloors(updated.getFloors());
        if (updated.getDescription() != null) building.setDescription(updated.getDescription());
        return buildingRepository.save(building);
    }

    public void delete(Long id) {
        buildingRepository.deleteById(id);
    }
}
