package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Complaint;
import com.cpms.service.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;

    @GetMapping
    public ApiResult<List<Complaint>> list(@RequestParam(required = false) Long ownerId,
                                           @RequestParam(required = false) String status) {
        if (ownerId != null) return ApiResult.success(complaintService.listByOwner(ownerId));
        if (status != null) return ApiResult.success(complaintService.listByStatus(status));
        return ApiResult.success(complaintService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Complaint> getById(@PathVariable Long id) {
        return ApiResult.success(complaintService.getById(id));
    }

    @PostMapping
    public ApiResult<Complaint> create(@RequestBody Complaint complaint) {
        return ApiResult.success(complaintService.create(complaint));
    }

    @PutMapping("/{id}/reply")
    public ApiResult<Complaint> reply(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return ApiResult.success(complaintService.reply(id, body.get("reply")));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        complaintService.delete(id);
        return ApiResult.success();
    }
}
