import 'dart:convert';

class CoinModel {
  final String id;
  final String name;
  final String symbol;
  final double price;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) => CoinModel(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    price: (json["price"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "price": price,
  };
}
