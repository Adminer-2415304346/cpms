package com.cpms.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "complaint")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long complaintId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private Owner owner;

    @Column(nullable = false, length = 15)
    private String type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    private Boolean isAnonymous;

    @Column(length = 15)
    private String status;

    @Column(columnDefinition = "TEXT")
    private String reply;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime repliedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null) status = "pending";
        if (isAnonymous == null) isAnonymous = false;
    }
}
