package com.cpms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "parking_spot")
public class ParkingSpot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long spotId;

    @Column(nullable = false, unique = true, length = 50)
    private String spotCode;

    @Column(length = 200)
    private String location;

    @Column(length = 50)
    private String type;

    @Column(length = 15)
    private String status;

    @PrePersist
    protected void onCreate() {
        if (status == null) status = "available";
    }
}
