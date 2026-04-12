import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/location_model.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

// Navigation
final selectedIndexProvider = StateProvider<int>((ref) => 0);

// Ride booking
final selectedRideTypeProvider = StateProvider<RideType>((ref) => RideType.bike);
final pickupLocationProvider = StateProvider<LocationModel?>((ref) => null);
final dropLocationProvider = StateProvider<LocationModel?>((ref) => null);
final currentLocationProvider = StateProvider<LocationModel?>((ref) => null);
final currentRideProvider = StateProvider<RideModel?>((ref) => null);

// Ride history (loaded from Hive)
final userRidesProvider = StateProvider<List<RideModel>>((ref) => []);

// Wallet
final walletBalanceProvider = StateProvider<double>((ref) => 250.00);
final transactionsProvider = StateProvider<List<TransactionModel>>((ref) => []);

// User
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// UI state
final isLocationLoadingProvider = StateProvider<bool>((ref) => false);

// Map controller
final mapControllerProvider = StateProvider<MapController?>((ref) => null);
