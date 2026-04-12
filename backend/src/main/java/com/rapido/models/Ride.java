package com.rapido.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "rides")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Ride {
    @Id
    private String id;
    private String rideType;
    private String status;
    private double pickupLat;
    private double pickupLng;
    private String pickupAddress;
    private double dropLat;
    private double dropLng;
    private String dropAddress;
    private double distance;
    private int duration;
    private double fare;
    private Long userId;
    private LocalDateTime createdAt;
}
