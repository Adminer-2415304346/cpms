package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Owner;
import com.cpms.service.OwnerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/owners")
@RequiredArgsConstructor
public class OwnerController {

    private final OwnerService ownerService;

    @GetMapping
    public ApiResult<List<Owner>> list() {
        return ApiResult.success(ownerService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Owner> getById(@PathVariable Long id) {
        return ApiResult.success(ownerService.getById(id));
    }

    @GetMapping("/by-user/{userId}")
    public ApiResult<Owner> getByUserId(@PathVariable Long userId) {
        return ApiResult.success(ownerService.getByUserId(userId));
    }

    @PostMapping
    public ApiResult<Owner> create(@RequestBody Owner owner) {
        return ApiResult.success(ownerService.create(owner));
    }

    @PutMapping("/{id}")
    public ApiResult<Owner> update(@PathVariable Long id, @RequestBody Owner owner) {
        return ApiResult.success(ownerService.update(id, owner));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        ownerService.delete(id);
        return ApiResult.success();
    }
}
