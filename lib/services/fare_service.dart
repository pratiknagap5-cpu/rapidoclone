import '../models/ride_model.dart';

class FareService {
  /// Base fare and per-km rates for each ride type
  static const Map<RideType, Map<String, double>> _rates = {
    RideType.bike: {'base': 25, 'perKm': 8},
    RideType.auto: {'base': 40, 'perKm': 12},
    RideType.cab: {'base': 70, 'perKm': 18},
    RideType.premiumCab: {'base': 120, 'perKm': 25},
    RideType.electricBike: {'base': 30, 'perKm': 10},
  };

  /// Calculate fare based on distance and ride type
  static double calculateFare(double distanceKm, RideType rideType) {
    final rates = _rates[rideType]!;
    double fare = rates['base']! + (distanceKm * rates['perKm']!);

    // Minimum fare
    if (fare < rates['base']! + 10) {
      fare = rates['base']! + 10;
    }

    return fare;
  }

  /// Get estimated time in minutes
  static int estimateTime(double distanceKm, RideType rideType) {
    // Average speeds in km/h
    const Map<RideType, double> avgSpeeds = {
      RideType.bike: 25,
      RideType.auto: 20,
      RideType.cab: 22,
      RideType.premiumCab: 22,
      RideType.electricBike: 20,
    };

    final speed = avgSpeeds[rideType]!;
    return ((distanceKm / speed) * 60).round().clamp(2, 180);
  }

  /// Get fare breakdown string
  static String getFareBreakdown(double distanceKm, RideType rideType) {
    final rates = _rates[rideType]!;
    final baseFare = rates['base']!;
    final distanceFare = distanceKm * rates['perKm']!;
    final total = calculateFare(distanceKm, rideType);

    return 'Base fare: ₹${baseFare.toStringAsFixed(0)}\n'
        'Distance (${distanceKm.toStringAsFixed(1)} km × ₹${rates['perKm']!.toStringAsFixed(0)}): '
        '₹${distanceFare.toStringAsFixed(0)}\n'
        'Total: ₹${total.toStringAsFixed(0)}';
  }

  /// Get rate description for ride type card
  static String getRateDescription(RideType rideType) {
    final rates = _rates[rideType]!;
    return '₹${rates['base']!.toStringAsFixed(0)} + ₹${rates['perKm']!.toStringAsFixed(0)}/km';
  }
}
