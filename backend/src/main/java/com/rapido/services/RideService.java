package com.rapido.services;

import com.rapido.models.Ride;
import com.rapido.repositories.RideRepository;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class RideService {
    private final RideRepository rideRepository;

    public RideService(RideRepository rideRepository) {
        this.rideRepository = rideRepository;
    }

    public Map<String, Object> calculateFare(double distance, String rideType) {
        double baseFare = 0;
        double perKmRate = 0;

        switch (rideType) {
            case "bike":
                baseFare = 25;
                perKmRate = 8;
                break;
            case "auto":
                baseFare = 40;
                perKmRate = 12;
                break;
            case "cab":
                baseFare = 70;
                perKmRate = 18;
                break;
            case "premiumCab":
                baseFare = 120;
                perKmRate = 25;
                break;
            case "electricBike":
                baseFare = 30;
                perKmRate = 10;
                break;
        }

        double fare = baseFare + (distance * perKmRate);
        Map<String, Object> result = new HashMap<>();
        result.put("fare", fare);
        result.put("distance", distance);
        result.put("estimatedDuration", (int)(distance * 3));
        return result;
    }

    public Ride saveRide(Ride ride) {
        return rideRepository.save(ride);
    }
}
