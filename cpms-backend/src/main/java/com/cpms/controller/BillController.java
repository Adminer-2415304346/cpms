package com.cpms.controller;

import com.cpms.dto.ApiResult;
import com.cpms.entity.Bill;
import com.cpms.entity.Payment;
import com.cpms.service.BillService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bills")
@RequiredArgsConstructor
public class BillController {

    private final BillService billService;

    @GetMapping
    public ApiResult<List<Bill>> list(@RequestParam(required = false) Long roomId,
                                      @RequestParam(required = false) Long buildingId,
                                      @RequestParam(required = false, defaultValue = "false") boolean unpaid) {
        if (unpaid) return ApiResult.success(billService.listUnpaid());
        if (roomId != null) return ApiResult.success(billService.listByRoom(roomId));
        if (buildingId != null) return ApiResult.success(billService.listByBuilding(buildingId));
        return ApiResult.success(billService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResult<Bill> getById(@PathVariable Long id) {
        return ApiResult.success(billService.getById(id));
    }

    @PostMapping
    public ApiResult<Bill> create(@RequestBody Bill bill) {
        return ApiResult.success(billService.create(bill));
    }

    @PutMapping("/{id}")
    public ApiResult<Bill> update(@PathVariable Long id, @RequestBody Bill bill) {
        return ApiResult.success(billService.update(id, bill));
    }

    @PostMapping("/{id}/pay")
    public ApiResult<Payment> pay(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String payMethod = (String) body.getOrDefault("payMethod", "线下缴费");
        Object staffIdObj = body.get("staffId");
        Long staffId = staffIdObj != null ? ((Number) staffIdObj).longValue() : null;
        return ApiResult.success(billService.pay(id, payMethod, staffId));
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> delete(@PathVariable Long id) {
        billService.delete(id);
        return ApiResult.success();
    }
}
