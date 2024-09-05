// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String userId;
  String userPw;
  String userName;
  DateTime userBirthdate;
  String userGender;
  String userPhone;
  String userLevel;
  String userType;
  DateTime joinedAt;

  UserModel({
    required this.userId,
    required this.userPw,
    required this.userName,
    required this.userBirthdate,
    required this.userGender,
    required this.userPhone,
    required this.userLevel,
    required this.userType,
    required this.joinedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json["user_id"],
    userPw: json["user_pw"],
    userName: json["user_name"],
    userBirthdate: DateTime.parse(json["user_birthdate"]),
    userGender: json["user_gender"],
    userPhone: json["user_phone"],
    userLevel: json['user_level'],
    userType: json["user_type"],
    joinedAt: DateTime.parse(json["joined_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "user_pw": userPw,
    "user_name": userName,
    "user_birthdate": userBirthdate.toIso8601String(),
    "user_gender": userGender,
    "user_phone": userPhone,
    "user_level": userLevel,
    "user_type": userType,
    "joined_at": joinedAt.toIso8601String(),
  };
}
