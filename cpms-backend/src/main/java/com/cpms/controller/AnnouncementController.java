package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Announcement;
import com.cpms.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    @GetMapping
    public ApiResult<List<Announcement>> list() {
        return ApiResult.success(announcementService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Announcement> getById(@PathVariable Long id) {
        return ApiResult.success(announcementService.getById(id));
    }

    @PostMapping
    public ApiResult<Announcement> create(@RequestBody Announcement announcement) {
        return ApiResult.success(announcementService.create(announcement));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        announcementService.delete(id);
        return ApiResult.success();
    }
}
