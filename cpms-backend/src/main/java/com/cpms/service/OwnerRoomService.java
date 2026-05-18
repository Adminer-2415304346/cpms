package com.cpms.service;

import com.cpms.entity.OwnerRoom;
import com.cpms.repository.OwnerRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OwnerRoomService {

    private final OwnerRoomRepository ownerRoomRepository;

    public List<OwnerRoom> listByOwner(Long ownerId) {
        return ownerRoomRepository.findByOwner_OwnerId(ownerId);
    }

    public List<OwnerRoom> listByRoom(Long roomId) {
        return ownerRoomRepository.findByRoom_RoomId(roomId);
    }

    public OwnerRoom bind(OwnerRoom ownerRoom) {
        if (ownerRoomRepository.existsByOwner_OwnerIdAndRoom_RoomId(
                ownerRoom.getOwner().getOwnerId(), ownerRoom.getRoom().getRoomId())) {
            throw new RuntimeException("该业主已绑定此房间");
        }
        return ownerRoomRepository.save(ownerRoom);
    }

    public void unbind(Long id) {
        ownerRoomRepository.deleteById(id);
    }
}
