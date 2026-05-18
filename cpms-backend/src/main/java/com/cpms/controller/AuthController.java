package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.dto.LoginRequest;
import com.cpms.dto.LoginResponse;
import com.cpms.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/login")
    public ApiResult<LoginResponse> login(@Valid @RequestBody LoginRequest req) {
        return ApiResult.success(userService.login(req));
    }
}
