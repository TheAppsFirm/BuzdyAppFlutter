import 'dart:convert';

class RugCheckModel {
  final int status;
  final String message;
  final RugCheckModelData? data;

  RugCheckModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory RugCheckModel.fromJson(Map<String, dynamic> json) => RugCheckModel(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] != null ? RugCheckModelData.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class RugCheckModelData {
  final bool safe;
  final String message;
  final String riskLevel;

  RugCheckModelData({
    required this.safe,
    required this.message,
    required this.riskLevel,
  });

  factory RugCheckModelData.fromJson(Map<String, dynamic> json) => RugCheckModelData(
    safe: json["safe"] ?? false,
    message: json["message"] ?? "",
    riskLevel: json["riskLevel"] ?? "Unknown",
  );

  Map<String, dynamic> toJson() => {
    "safe": safe,
    "message": message,
    "riskLevel": riskLevel,
  };
}
