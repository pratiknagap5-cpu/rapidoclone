import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 6)
enum PaymentMethod {
  @HiveField(0)
  upi,
  @HiveField(1)
  card,
  @HiveField(2)
  cash,
}

@HiveType(typeId: 7)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rideId;

  @HiveField(2)
  final int methodIndex;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime timestamp;

  PaymentModel({
    required this.id,
    required this.rideId,
    required this.methodIndex,
    required this.amount,
    required this.timestamp,
  });

  PaymentMethod get method => PaymentMethod.values[methodIndex];

  String get methodName {
    switch (method) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get methodIcon {
    switch (method) {
      case PaymentMethod.upi:
        return '📱';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.cash:
        return '💵';
    }
  }
}
