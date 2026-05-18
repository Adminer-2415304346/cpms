package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Room;
import com.cpms.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;

    @GetMapping
    public ApiResult<List<Room>> list(@RequestParam(required = false) Long buildingId) {
        if (buildingId != null) {
            return ApiResult.success(roomService.listByBuilding(buildingId));
        }
        return ApiResult.success(roomService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Room> getById(@PathVariable Long id) {
        return ApiResult.success(roomService.getById(id));
    }

    @PostMapping
    public ApiResult<Room> create(@RequestBody Room room) {
        return ApiResult.success(roomService.create(room));
    }

    @PutMapping("/{id}")
    public ApiResult<Room> update(@PathVariable Long id, @RequestBody Room room) {
        return ApiResult.success(roomService.update(id, room));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        roomService.delete(id);
        return ApiResult.success();
    }
}
