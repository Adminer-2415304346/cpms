package com.cpms.repository;

import com.cpms.entity.Repair;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RepairRepository extends JpaRepository<Repair, Long> {
    List<Repair> findByOwner_OwnerId(Long ownerId);
    List<Repair> findByStatus(String status);
    List<Repair> findByStaff_UserId(Long staffId);
    long countByStatusIn(List<String> statuses);
}
