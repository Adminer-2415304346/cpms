package com.cpms.service;

import com.cpms.entity.Building;
import com.cpms.entity.Room;
import com.cpms.exception.NotFoundException;
import com.cpms.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final RoomRepository roomRepository;
    private final BuildingService buildingService;

    public List<Room> listByBuilding(Long buildingId) {
        return roomRepository.findByBuilding_BuildingId(buildingId);
    }

    public List<Room> listAll() {
        return roomRepository.findAll();
    }

    public Room getById(Long id) {
        return roomRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("房间不存在"));
    }

    public Room create(Room room) {
        if (room.getBuilding() != null && room.getBuilding().getBuildingId() != null) {
            Building building = buildingService.getById(room.getBuilding().getBuildingId());
            room.setBuilding(building);
        }
        if (room.getStatus() == null) room.setStatus("vacant");
        return roomRepository.save(room);
    }

    public Room update(Long id, Room updated) {
        Room room = getById(id);
        if (updated.getUnitName() != null) room.setUnitName(updated.getUnitName());
        if (updated.getRoomNumber() != null) room.setRoomNumber(updated.getRoomNumber());
        if (updated.getArea() != null) room.setArea(updated.getArea());
        if (updated.getRoomType() != null) room.setRoomType(updated.getRoomType());
        if (updated.getStatus() != null) room.setStatus(updated.getStatus());
        return roomRepository.save(room);
    }

    public void delete(Long id) {
        roomRepository.deleteById(id);
    }
}
