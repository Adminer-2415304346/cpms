package com.cpms.repository;

import com.cpms.entity.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Long> {
    List<Complaint> findByOwner_OwnerId(Long ownerId);
    List<Complaint> findByStatus(String status);
}
