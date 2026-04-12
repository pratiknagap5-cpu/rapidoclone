import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phoneNumber;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? profileImage;

  UserModel({
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'profileImage': profileImage,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
        email: json['email'] as String,
        profileImage: json['profileImage'] as String?,
      );
}
