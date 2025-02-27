import 'dart:convert';

class MerchantModel {
  final int status;
  final String message;
  final List<Merchant> merchants;

  MerchantModel({
    required this.status,
    required this.message,
    required this.merchants,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
    status: json["status"],
    message: json["message"],
    merchants: List<Merchant>.from(json["merchants"].map((x) => Merchant.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "merchants": List<dynamic>.from(merchants.map((x) => x.toJson())),
  };
}

class Merchant {
  final int id;
  final String name;

  Merchant({
    required this.id,
    required this.name,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
