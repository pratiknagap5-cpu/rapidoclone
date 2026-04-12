// GENERATED CODE - hand-written Hive TypeAdapters for RideModel

part of 'ride_model.dart';

class RideTypeAdapter extends TypeAdapter<RideType> {
  @override
  final int typeId = 1;

  @override
  RideType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RideType.bike;
      case 1:
        return RideType.auto;
      case 2:
        return RideType.cab;
      case 3:
        return RideType.premiumCab;
      case 4:
        return RideType.electricBike;
      default:
        return RideType.bike;
    }
  }

  @override
  void write(BinaryWriter writer, RideType obj) {
    switch (obj) {
      case RideType.bike:
        writer.writeByte(0);
        break;
      case RideType.auto:
        writer.writeByte(1);
        break;
      case RideType.cab:
        writer.writeByte(2);
        break;
      case RideType.premiumCab:
        writer.writeByte(3);
        break;
      case RideType.electricBike:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RideStatusAdapter extends TypeAdapter<RideStatus> {
  @override
  final int typeId = 2;

  @override
  RideStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RideStatus.searching;
      case 1:
        return RideStatus.accepted;
      case 2:
        return RideStatus.arrived;
      case 3:
        return RideStatus.started;
      case 4:
        return RideStatus.completed;
      case 5:
        return RideStatus.cancelled;
      default:
        return RideStatus.searching;
    }
  }

  @override
  void write(BinaryWriter writer, RideStatus obj) {
    switch (obj) {
      case RideStatus.searching:
        writer.writeByte(0);
        break;
      case RideStatus.accepted:
        writer.writeByte(1);
        break;
      case RideStatus.arrived:
        writer.writeByte(2);
        break;
      case RideStatus.started:
        writer.writeByte(3);
        break;
      case RideStatus.completed:
        writer.writeByte(4);
        break;
      case RideStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RideModelAdapter extends TypeAdapter<RideModel> {
  @override
  final int typeId = 3;

  @override
  RideModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideModel(
      id: fields[0] as String,
      rideTypeIndex: fields[1] as int,
      rideStatusIndex: fields[2] as int,
      pickupLat: fields[3] as double,
      pickupLng: fields[4] as double,
      pickupAddress: fields[5] as String,
      dropLat: fields[6] as double,
      dropLng: fields[7] as double,
      dropAddress: fields[8] as String,
      distance: fields[9] as double,
      duration: fields[10] as int,
      fare: fields[11] as double,
      createdAt: fields[12] as DateTime,
      completedAt: fields[13] as DateTime?,
      paymentMethod: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RideModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rideTypeIndex)
      ..writeByte(2)
      ..write(obj.rideStatusIndex)
      ..writeByte(3)
      ..write(obj.pickupLat)
      ..writeByte(4)
      ..write(obj.pickupLng)
      ..writeByte(5)
      ..write(obj.pickupAddress)
      ..writeByte(6)
      ..write(obj.dropLat)
      ..writeByte(7)
      ..write(obj.dropLng)
      ..writeByte(8)
      ..write(obj.dropAddress)
      ..writeByte(9)
      ..write(obj.distance)
      ..writeByte(10)
      ..write(obj.duration)
      ..writeByte(11)
      ..write(obj.fare)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.completedAt)
      ..writeByte(14)
      ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
