package com.cpms.repository;

import com.cpms.entity.Owner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface OwnerRepository extends JpaRepository<Owner, Long> {
    Optional<Owner> findByUser_UserId(Long userId);
    boolean existsByIdCard(String idCard);
}
