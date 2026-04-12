// GENERATED CODE - hand-written Hive TypeAdapters for PaymentModel

part of 'payment_model.dart';

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 6;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.upi;
      case 1:
        return PaymentMethod.card;
      case 2:
        return PaymentMethod.cash;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.upi:
        writer.writeByte(0);
        break;
      case PaymentMethod.card:
        writer.writeByte(1);
        break;
      case PaymentMethod.cash:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 7;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      rideId: fields[1] as String,
      methodIndex: fields[2] as int,
      amount: fields[3] as double,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rideId)
      ..writeByte(2)
      ..write(obj.methodIndex)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
