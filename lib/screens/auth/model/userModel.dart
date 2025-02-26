// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final int status;
  final String message;
  final UserModelData data;

  UserModel({
    required this.status,
    required this.message,
    required this.data,
  });

  UserModel copyWith({
    int? status,
    String? message,
    UserModelData? data,
  }) =>
      UserModel(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        status: json["status"],
        message: json["message"],
        data: UserModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class UserModelData {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String token;

  UserModelData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.token,
  });

  UserModelData copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? token,
  }) =>
      UserModelData(
        id: id ?? this.id,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        email: email ?? this.email,
        token: token ?? this.token,
      );

  factory UserModelData.fromJson(Map<String, dynamic> json) => UserModelData(
        id: json["id"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        email: json["email"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "token": token,
      };
}
