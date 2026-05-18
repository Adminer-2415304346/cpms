package com.cpms.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Entity
@Table(name = "room")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long roomId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "building_id", nullable = false)
    private Building building;

    @Column(length = 50)
    private String unitName;

    @Column(nullable = false, length = 20)
    private String roomNumber;

    @Column(precision = 10, scale = 2)
    private BigDecimal area;

    @Column(length = 50)
    private String roomType;

    @Column(length = 15)
    private String status;
}
