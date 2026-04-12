import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_model.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  static const String _ridesBox = 'rides';
  static const String _paymentsBox = 'payments';
  static const String _transactionsBox = 'transactions';
  static const String _userBox = 'user';
  static const String _settingsBox = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(LocationModelAdapter());
    Hive.registerAdapter(RideTypeAdapter());
    Hive.registerAdapter(RideStatusAdapter());
    Hive.registerAdapter(RideModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(PaymentMethodAdapter());
    Hive.registerAdapter(PaymentModelAdapter());

    // Open boxes
    await Hive.openBox<RideModel>(_ridesBox);
    await Hive.openBox<PaymentModel>(_paymentsBox);
    await Hive.openBox<TransactionModel>(_transactionsBox);
    await Hive.openBox(_userBox);
    await Hive.openBox(_settingsBox);
  }

  // ==================== RIDES ====================

  static Future<void> saveRide(RideModel ride) async {
    final box = Hive.box<RideModel>(_ridesBox);
    await box.put(ride.id, ride);
  }

  static List<RideModel> getAllRides() {
    final box = Hive.box<RideModel>(_ridesBox);
    final rides = box.values.toList();
    rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rides;
  }

  static Future<void> updateRideStatus(String rideId, RideStatus status) async {
    final box = Hive.box<RideModel>(_ridesBox);
    final ride = box.get(rideId);
    if (ride != null) {
      ride.rideStatusIndex = status.index;
      if (status == RideStatus.completed) {
        ride.completedAt = DateTime.now();
      }
      await ride.save();
    }
  }

  static Future<void> updateRidePayment(String rideId, String paymentMethod) async {
    final box = Hive.box<RideModel>(_ridesBox);
    final ride = box.get(rideId);
    if (ride != null) {
      ride.paymentMethod = paymentMethod;
      await ride.save();
    }
  }

  // ==================== PAYMENTS ====================

  static Future<void> savePayment(PaymentModel payment) async {
    final box = Hive.box<PaymentModel>(_paymentsBox);
    await box.put(payment.id, payment);
  }

  static List<PaymentModel> getAllPayments() {
    final box = Hive.box<PaymentModel>(_paymentsBox);
    final payments = box.values.toList();
    payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return payments;
  }

  // ==================== TRANSACTIONS ====================

  static Future<void> saveTransaction(TransactionModel transaction) async {
    final box = Hive.box<TransactionModel>(_transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static List<TransactionModel> getAllTransactions() {
    final box = Hive.box<TransactionModel>(_transactionsBox);
    final transactions = box.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // ==================== USER ====================

  static Future<void> saveUserProfile(UserModel user) async {
    final box = Hive.box(_userBox);
    await box.put('name', user.name);
    await box.put('phone', user.phoneNumber);
    await box.put('email', user.email);
    await box.put('profileImage', user.profileImage);
  }

  static UserModel? getUserProfile() {
    final box = Hive.box(_userBox);
    final name = box.get('name');
    if (name == null) return null;
    return UserModel(
      name: name as String,
      phoneNumber: box.get('phone', defaultValue: '') as String,
      email: box.get('email', defaultValue: '') as String,
      profileImage: box.get('profileImage') as String?,
    );
  }

  // ==================== SETTINGS ====================

  static Future<void> setWalletBalance(double balance) async {
    final box = Hive.box(_settingsBox);
    await box.put('walletBalance', balance);
  }

  static double getWalletBalance() {
    final box = Hive.box(_settingsBox);
    return box.get('walletBalance', defaultValue: 250.0) as double;
  }

  static Future<void> clearAll() async {
    await Hive.box<RideModel>(_ridesBox).clear();
    await Hive.box<PaymentModel>(_paymentsBox).clear();
    await Hive.box<TransactionModel>(_transactionsBox).clear();
    await Hive.box(_userBox).clear();
    await Hive.box(_settingsBox).clear();
  }
}
