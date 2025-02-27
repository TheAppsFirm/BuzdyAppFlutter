import 'dart:convert';

class BankModel {
  final int status;
  final String message;
  final List<Bank> banks;

  BankModel({
    required this.status,
    required this.message,
    required this.banks,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
    status: json["status"],
    message: json["message"],
    banks: List<Bank>.from(json["banks"].map((x) => Bank.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "banks": List<dynamic>.from(banks.map((x) => x.toJson())),
  };
}

class Bank {
  final int id;
  final String name;
  final String email;

  Bank({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}
