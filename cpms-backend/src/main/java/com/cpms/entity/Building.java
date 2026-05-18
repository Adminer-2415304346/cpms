package com.cpms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "building")
public class Building {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long buildingId;

    @Column(nullable = false, length = 100)
    private String buildingName;

    private Integer floors;

    @Column(columnDefinition = "TEXT")
    private String description;
}
