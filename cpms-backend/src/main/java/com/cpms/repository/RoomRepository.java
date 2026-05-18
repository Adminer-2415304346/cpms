package com.cpms.repository;

import com.cpms.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {
    List<Room> findByBuilding_BuildingId(Long buildingId);
    List<Room> findByStatus(String status);
}
