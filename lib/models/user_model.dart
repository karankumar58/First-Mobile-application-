// models/user_model.dart
import '../enums/app_enums.dart';

class UserModel {
  final String fullName;
  final String email;
  final Gender gender;
  final String password;

  UserModel({
    required this.fullName,
    required this.email,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'gender': gender.name,
      'password': password,
    };
  }
}
