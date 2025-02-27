import 'dart:convert';

List<BubbleCoinModel> bubbleCoinModelFromJson(String str) =>
    List<BubbleCoinModel>.from(
        json.decode(str).map((x) => BubbleCoinModel.fromJson(x)));

String bubbleCoinModelToJson(List<BubbleCoinModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BubbleCoinModel {
  final String id;
  final String name;
  final String slug;
  final String symbol;
  final double dominance;
  final String image;
  final int rank;
  final bool stable;
  final double price;
  final int marketcap;
  final int volume;
  final String cgId;
  final Symbols symbols;
  final Map<String, double> performance;
  final Map<String, double> rankDiffs;
  final Map<String, double> exchangePrices;

  BubbleCoinModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.symbol,
    required this.dominance,
    required this.image,
    required this.rank,
    required this.stable,
    required this.price,
    required this.marketcap,
    required this.volume,
    required this.cgId,
    required this.symbols,
    required this.performance,
    required this.rankDiffs,
    required this.exchangePrices,
  });

  factory BubbleCoinModel.fromJson(Map<String, dynamic> json) =>
      BubbleCoinModel(
        id: json["id"]?.toString() ?? "",
        name: json["name"] ?? "Unknown",
        slug: json["slug"] ?? "",
        symbol: json["symbol"] ?? "N/A",
        dominance: _toDouble(json["dominance"]),
        image: json["image"] ?? "",
        rank: json["rank"] ?? 0,
        stable: json["stable"] ?? false,
        price: _toDouble(json["price"]),
        marketcap: json["marketcap"] ?? 0,
        volume: json["volume"] ?? 0,
        cgId: json["cg_id"] ?? "",
        symbols: Symbols.fromJson(json["symbols"] ?? {}),
        performance: _parseMap(json["performance"]),
        rankDiffs: _parseMap(json["rankDiffs"]),
        exchangePrices: _parseMap(json["exchangePrices"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "symbol": symbol,
        "dominance": dominance,
        "image": image,
        "rank": rank,
        "stable": stable,
        "price": price,
        "marketcap": marketcap,
        "volume": volume,
        "cg_id": cgId,
        "symbols": symbols.toJson(),
        "performance": performance,
        "rankDiffs": rankDiffs,
        "exchangePrices": exchangePrices,
      };

  /// **Helper Function to Parse Map<String, double> Safely**
  static Map<String, double> _parseMap(dynamic json) {
    if (json is Map) {
      return json.map((key, value) {
        if (key is String) {
          return MapEntry(key, _toDouble(value));
        }
        return MapEntry(key.toString(), _toDouble(value));
      });
    }
    return {};
  }

  /// **Helper Function to Convert Values to Double**
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class Symbols {
  final String bybit;
  final String bitget;
  final String bingx;
  final String bitmart;
  final String gateio;
  final String okx;
  final String kucoin;
  final String coinbase;
  final String mexc;
  final String kraken;
  final String cryptocom;
  final String binance;

  Symbols({
    required this.bybit,
    required this.bitget,
    required this.bingx,
    required this.bitmart,
    required this.gateio,
    required this.okx,
    required this.kucoin,
    required this.coinbase,
    required this.mexc,
    required this.kraken,
    required this.cryptocom,
    required this.binance,
  });

  factory Symbols.fromJson(Map<String, dynamic>? json) => Symbols(
        bybit: json?["bybit"] ?? "N/A",
        bitget: json?["bitget"] ?? "N/A",
        bingx: json?["bingx"] ?? "N/A",
        bitmart: json?["bitmart"] ?? "N/A",
        gateio: json?["gateio"] ?? "N/A",
        okx: json?["okx"] ?? "N/A",
        kucoin: json?["kucoin"] ?? "N/A",
        coinbase: json?["coinbase"] ?? "N/A",
        mexc: json?["mexc"] ?? "N/A",
        kraken: json?["kraken"] ?? "N/A",
        cryptocom: json?["cryptocom"] ?? "N/A",
        binance: json?["binance"] ?? "N/A",
      );

  Map<String, dynamic> toJson() => {
        "bybit": bybit,
        "bitget": bitget,
        "bingx": bingx,
        "bitmart": bitmart,
        "gateio": gateio,
        "okx": okx,
        "kucoin": kucoin,
        "coinbase": coinbase,
        "mexc": mexc,
        "kraken": kraken,
        "cryptocom": cryptocom,
        "binance": binance,
      };
}
