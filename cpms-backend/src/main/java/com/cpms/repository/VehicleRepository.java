package com.cpms.repository;

import com.cpms.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    List<Vehicle> findByOwner_OwnerId(Long ownerId);
    boolean existsByPlateNumber(String plateNumber);
}
