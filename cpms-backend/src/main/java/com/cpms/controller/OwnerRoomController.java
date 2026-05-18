package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.OwnerRoom;
import com.cpms.service.OwnerRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/owner-rooms")
@RequiredArgsConstructor
public class OwnerRoomController {

    private final OwnerRoomService ownerRoomService;

    @GetMapping("/by-owner/{ownerId}")
    public ApiResult<List<OwnerRoom>> listByOwner(@PathVariable Long ownerId) {
        return ApiResult.success(ownerRoomService.listByOwner(ownerId));
    }

    @GetMapping("/by-room/{roomId}")
    public ApiResult<List<OwnerRoom>> listByRoom(@PathVariable Long roomId) {
        return ApiResult.success(ownerRoomService.listByRoom(roomId));
    }

    @PostMapping
    public ApiResult<OwnerRoom> bind(@RequestBody OwnerRoom ownerRoom) {
        return ApiResult.success(ownerRoomService.bind(ownerRoom));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> unbind(@PathVariable Long id) {
        ownerRoomService.unbind(id);
        return ApiResult.success();
    }
}
