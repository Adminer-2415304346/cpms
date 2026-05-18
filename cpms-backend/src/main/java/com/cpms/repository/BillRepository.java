package com.cpms.repository;

import com.cpms.entity.Bill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BillRepository extends JpaRepository<Bill, Long> {
    List<Bill> findByRoom_RoomId(Long roomId);
    List<Bill> findByStatusIn(List<String> statuses);
    List<Bill> findByRoom_Building_BuildingId(Long buildingId);
}
