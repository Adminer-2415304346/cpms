package com.cpms.repository;

import com.cpms.entity.OwnerRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OwnerRoomRepository extends JpaRepository<OwnerRoom, Long> {
    List<OwnerRoom> findByOwner_OwnerId(Long ownerId);
    List<OwnerRoom> findByRoom_RoomId(Long roomId);
    boolean existsByOwner_OwnerIdAndRoom_RoomId(Long ownerId, Long roomId);
}
