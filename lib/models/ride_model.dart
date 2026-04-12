import 'package:hive/hive.dart';
import 'location_model.dart';

part 'ride_model.g.dart';

@HiveType(typeId: 1)
enum RideType {
  @HiveField(0)
  bike,
  @HiveField(1)
  auto,
  @HiveField(2)
  cab,
  @HiveField(3)
  premiumCab,
  @HiveField(4)
  electricBike,
}

@HiveType(typeId: 2)
enum RideStatus {
  @HiveField(0)
  searching,
  @HiveField(1)
  accepted,
  @HiveField(2)
  arrived,
  @HiveField(3)
  started,
  @HiveField(4)
  completed,
  @HiveField(5)
  cancelled,
}

@HiveType(typeId: 3)
class RideModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int rideTypeIndex;

  @HiveField(2)
  int rideStatusIndex;

  @HiveField(3)
  final double pickupLat;

  @HiveField(4)
  final double pickupLng;

  @HiveField(5)
  final String pickupAddress;

  @HiveField(6)
  final double dropLat;

  @HiveField(7)
  final double dropLng;

  @HiveField(8)
  final String dropAddress;

  @HiveField(9)
  final double distance;

  @HiveField(10)
  final int duration;

  @HiveField(11)
  final double fare;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  DateTime? completedAt;

  @HiveField(14)
  String? paymentMethod;

  RideModel({
    required this.id,
    required this.rideTypeIndex,
    required this.rideStatusIndex,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropLat,
    required this.dropLng,
    required this.dropAddress,
    required this.distance,
    required this.duration,
    required this.fare,
    required this.createdAt,
    this.completedAt,
    this.paymentMethod,
  });

  RideType get rideType => RideType.values[rideTypeIndex];
  RideStatus get status => RideStatus.values[rideStatusIndex];

  LocationModel get pickupLocation => LocationModel(
        latitude: pickupLat,
        longitude: pickupLng,
        address: pickupAddress,
      );

  LocationModel get dropLocation => LocationModel(
        latitude: dropLat,
        longitude: dropLng,
        address: dropAddress,
      );

  set status(RideStatus s) => rideStatusIndex = s.index;

  String get rideTypeName {
    switch (rideType) {
      case RideType.bike:
        return 'Bike';
      case RideType.auto:
        return 'Auto';
      case RideType.cab:
        return 'Cab';
      case RideType.premiumCab:
        return 'Premium';
      case RideType.electricBike:
        return 'E-Bike';
    }
  }

  String get statusName {
    switch (status) {
      case RideStatus.searching:
        return 'Searching';
      case RideStatus.accepted:
        return 'Accepted';
      case RideStatus.arrived:
        return 'Arrived';
      case RideStatus.started:
        return 'In Progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rideType': rideTypeIndex,
        'status': rideStatusIndex,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'dropLat': dropLat,
        'dropLng': dropLng,
        'dropAddress': dropAddress,
        'distance': distance,
        'duration': duration,
        'fare': fare,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'paymentMethod': paymentMethod,
      };
}
