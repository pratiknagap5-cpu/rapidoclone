package com.rapido.controllers;

import com.rapido.models.Ride;
import com.rapido.services.RideService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class RideController {
    
    private final RideService rideService;
    
    public RideController(RideService rideService) {
        this.rideService = rideService;
    }
    
    @PostMapping("/rides")
    public ResponseEntity<Map<String, Object>> saveRide(@RequestBody Map<String, Object> rideData) {
        Ride ride = new Ride();
        ride.setId((String) rideData.get("id"));
        ride.setRideType((String) rideData.get("rideType"));
        ride.setPickupAddress((String) rideData.get("pickupLocation"));
        ride.setDropAddress((String) rideData.get("dropLocation"));
        ride.setDistance(((Number) rideData.get("distance")).doubleValue());
        ride.setFare(((Number) rideData.get("fare")).doubleValue());
        ride.setCreatedAt(java.time.LocalDateTime.now());
        
        Ride savedRide = rideService.saveRide(ride);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Ride saved successfully");
        response.put("ride", savedRide);
        return ResponseEntity.ok(response);
    }
}
