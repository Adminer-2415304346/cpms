package com.cpms.service;

import com.cpms.entity.Bill;
import com.cpms.entity.Payment;
import com.cpms.entity.Room;
import com.cpms.entity.User;
import com.cpms.exception.NotFoundException;
import com.cpms.repository.BillRepository;
import com.cpms.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BillService {

    private final BillRepository billRepository;
    private final PaymentRepository paymentRepository;
    private final RoomService roomService;

    public List<Bill> listAll() {
        return billRepository.findAll();
    }

    public List<Bill> listByRoom(Long roomId) {
        return billRepository.findByRoom_RoomId(roomId);
    }

    public List<Bill> listByBuilding(Long buildingId) {
        return billRepository.findByRoom_Building_BuildingId(buildingId);
    }

    public List<Bill> listUnpaid() {
        return billRepository.findByStatusIn(List.of("unpaid", "overdue"));
    }

    public Bill getById(Long id) {
        return billRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("账单不存在"));
    }

    public Bill create(Bill bill) {
        if (bill.getRoom() != null && bill.getRoom().getRoomId() != null) {
            Room room = roomService.getById(bill.getRoom().getRoomId());
            bill.setRoom(room);
        }
        if (bill.getStatus() == null) bill.setStatus("unpaid");
        return billRepository.save(bill);
    }

    public Bill update(Long id, Bill updated) {
        Bill bill = getById(id);
        if ("paid".equals(bill.getStatus())) {
            throw new RuntimeException("已缴费账单不可修改");
        }
        if (updated.getAmount() != null) bill.setAmount(updated.getAmount());
        if (updated.getDueDate() != null) bill.setDueDate(updated.getDueDate());
        if (updated.getFeeType() != null) bill.setFeeType(updated.getFeeType());
        return billRepository.save(bill);
    }

    @Transactional
    public Payment pay(Long billId, String payMethod, Long staffId) {
        Bill bill = getById(billId);
        if ("paid".equals(bill.getStatus())) {
            throw new RuntimeException("该账单已缴费");
        }
        bill.setStatus("paid");
        Payment payment = new Payment();
        payment.setBill(bill);
        payment.setAmount(bill.getAmount());
        payment.setPayMethod(payMethod);
        if (staffId != null) {
            User staff = new User();
            staff.setUserId(staffId);
            payment.setStaff(staff);
        }
        return paymentRepository.save(payment);
    }

    public void delete(Long id) {
        billRepository.deleteById(id);
    }
}
