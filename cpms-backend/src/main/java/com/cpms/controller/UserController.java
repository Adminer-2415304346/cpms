package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.User;
import com.cpms.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public ApiResult<List<User>> list(@RequestParam(required = false) String role) {
        if (role != null && !role.isEmpty()) {
            return ApiResult.success(userService.listByRole(role));
        }
        return ApiResult.success(userService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<User> getById(@PathVariable Long id) {
        return ApiResult.success(userService.getById(id));
    }

    @PostMapping
    public ApiResult<User> create(@RequestBody User user) {
        return ApiResult.success(userService.create(user));
    }

    @PutMapping("/{id}")
    public ApiResult<User> update(@PathVariable Long id, @RequestBody User user) {
        return ApiResult.success(userService.update(id, user));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ApiResult.success();
    }
}
