import 'dart:convert';

// Function to convert JSON string to List<CoinModel>
List<CoinModel> coinModelFromJson(String str) =>
    List<CoinModel>.from(json.decode(str).map((x) => CoinModel.fromJson(x)));

// Function to convert List<CoinModel> to JSON string
String coinModelToJson(List<CoinModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Delta {
  final double hour;
  final double day;
  final double week;
  final double month;
  final double quarter;
  final double year;

  Delta({
    required this.hour,
    required this.day,
    required this.week,
    required this.month,
    required this.quarter,
    required this.year,
  });

  factory Delta.fromJson(Map<String, dynamic> json) => Delta(
        hour: (json["hour"] ?? 0).toDouble(),
        day: (json["day"] ?? 0).toDouble(),
        week: (json["week"] ?? 0).toDouble(),
        month: (json["month"] ?? 0).toDouble(),
        quarter: (json["quarter"] ?? 0).toDouble(),
        year: (json["year"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "hour": hour,
        "day": day,
        "week": week,
        "month": month,
        "quarter": quarter,
        "year": year,
      };
}

class CoinModel {
  // Old keys
  final String mint;
  final String name;
  final String symbol;
  final String description;
  final String imageUri;
  final String metadataUri;
  final String twitter;
  final String telegram;
  final String bondingCurve;
  final String associatedBondingCurve;
  final String creator;
  final int createdTimestamp;
  final dynamic raydiumPool;
  final bool complete;
  final int virtualSolReserves;
  final int virtualTokenReserves;
  final dynamic hidden;
  final int totalSupply;
  final String website;
  final bool showName;
  final int lastTradeTimestamp;
  final dynamic kingOfTheHillTimestamp;
  final double marketCap;
  final int replyCount;
  final int? lastReply;
  final bool nsfw;
  final dynamic marketId;
  final dynamic inverted;
  final bool isCurrentlyLive;
  final dynamic username;
  final dynamic profileImage;
  final double usdMarketCap;
  
  // New keys from the LiveCoinWatch API response
  final int? rank;
  final int? age;
  final String? color;
  final String? png32;
  final String? png64;
  final String? webp32;
  final String? webp64;
  final int? exchanges;
  final int? markets;
  final int? pairs;
  final double? allTimeHighUSD;
  final double? circulatingSupply;
  final double? maxSupply;
  final String? code;
  final double? rate;
  final double? volume;
  final double? cap;
  final List<String>? categories;
  final Delta? delta;

  CoinModel({
    // Old keys
    required this.mint,
    required this.name,
    required this.symbol,
    required this.description,
    required this.imageUri,
    required this.metadataUri,
    required this.twitter,
    required this.telegram,
    required this.bondingCurve,
    required this.associatedBondingCurve,
    required this.creator,
    required this.createdTimestamp,
    this.raydiumPool,
    required this.complete,
    required this.virtualSolReserves,
    required this.virtualTokenReserves,
    this.hidden,
    required this.totalSupply,
    required this.website,
    required this.showName,
    required this.lastTradeTimestamp,
    this.kingOfTheHillTimestamp,
    required this.marketCap,
    required this.replyCount,
    this.lastReply,
    required this.nsfw,
    this.marketId,
    this.inverted,
    required this.isCurrentlyLive,
    this.username,
    this.profileImage,
    required this.usdMarketCap,
    // New keys
    this.rank,
    this.age,
    this.color,
    this.png32,
    this.png64,
    this.webp32,
    this.webp64,
    this.exchanges,
    this.markets,
    this.pairs,
    this.allTimeHighUSD,
    this.circulatingSupply,
    this.maxSupply,
    this.code,
    this.rate,
    this.volume,
    this.cap,
    this.categories,
    this.delta,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) => CoinModel(
        // Old keys
        mint: json["mint"] ?? "",
        name: json["name"] ?? "Unknown Name",
        symbol: json["symbol"] ?? "N/A",
        description: json["description"] ?? "No description available",
        imageUri: json["image_uri"] ?? "",
        metadataUri: json["metadata_uri"] ?? "",
        twitter: json["twitter"] ?? "",
        telegram: json["telegram"] ?? "",
        bondingCurve: json["bonding_curve"] ?? "",
        associatedBondingCurve: json["associated_bonding_curve"] ?? "",
        creator: json["creator"] ?? "",
        createdTimestamp: json["created_timestamp"] ?? 0,
        raydiumPool: json["raydium_pool"],
        complete: json["complete"] ?? false,
        virtualSolReserves: json["virtual_sol_reserves"] ?? 0,
        virtualTokenReserves: json["virtual_token_reserves"] ?? 0,
        hidden: json["hidden"],
        totalSupply: json["total_supply"] ?? 0,
        website: json["website"] ?? "",
        showName: json["show_name"] ?? false,
        lastTradeTimestamp: json["last_trade_timestamp"] ?? 0,
        kingOfTheHillTimestamp: json["king_of_the_hill_timestamp"],
        marketCap: (json["market_cap"] ?? 0).toDouble(),
        replyCount: json["reply_count"] ?? 0,
        lastReply: json["last_reply"],
        nsfw: json["nsfw"] ?? false,
        marketId: json["market_id"],
        inverted: json["inverted"],
        isCurrentlyLive: json["is_currently_live"] ?? false,
        username: json["username"],
        profileImage: json["profile_image"],
        usdMarketCap: (json["usd_market_cap"] ?? 0).toDouble(),
        // New keys from the LiveCoinWatch API response
        rank: json["rank"],
        age: json["age"],
        color: json["color"] ?? "#000000",
        png32: json["png32"] ?? "",
        png64: json["png64"] ?? "",
        webp32: json["webp32"] ?? "",
        webp64: json["webp64"] ?? "",
        exchanges: json["exchanges"],
        markets: json["markets"],
        pairs: json["pairs"],
        allTimeHighUSD: json["allTimeHighUSD"] != null ? (json["allTimeHighUSD"]).toDouble() : null,
        circulatingSupply: json["circulatingSupply"] != null ? (json["circulatingSupply"]).toDouble() : null,
        maxSupply: json["maxSupply"] != null ? (json["maxSupply"]).toDouble() : null,
        code: json["code"] ?? "",
        rate: json["rate"] != null ? (json["rate"]).toDouble() : null,
        volume: json["volume"] != null ? (json["volume"]).toDouble() : null,
        cap: json["cap"] != null ? (json["cap"]).toDouble() : null,
        categories: json["categories"] != null
            ? List<String>.from(json["categories"].map((x) => x.toString()))
            : [],
        delta: json["delta"] != null ? Delta.fromJson(json["delta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        // Old keys
        "mint": mint,
        "name": name,
        "symbol": symbol,
        "description": description,
        "image_uri": imageUri,
        "metadata_uri": metadataUri,
        "twitter": twitter,
        "telegram": telegram,
        "bonding_curve": bondingCurve,
        "associated_bonding_curve": associatedBondingCurve,
        "creator": creator,
        "created_timestamp": createdTimestamp,
        "raydium_pool": raydiumPool,
        "complete": complete,
        "virtual_sol_reserves": virtualSolReserves,
        "virtual_token_reserves": virtualTokenReserves,
        "hidden": hidden,
        "total_supply": totalSupply,
        "website": website,
        "show_name": showName,
        "last_trade_timestamp": lastTradeTimestamp,
        "king_of_the_hill_timestamp": kingOfTheHillTimestamp,
        "market_cap": marketCap,
        "reply_count": replyCount,
        "last_reply": lastReply,
        "nsfw": nsfw,
        "market_id": marketId,
        "inverted": inverted,
        "is_currently_live": isCurrentlyLive,
        "username": username,
        "profile_image": profileImage,
        "usd_market_cap": usdMarketCap,
        // New keys
        "rank": rank,
        "age": age,
        "color": color,
        "png32": png32,
        "png64": png64,
        "webp32": webp32,
        "webp64": webp64,
        "exchanges": exchanges,
        "markets": markets,
        "pairs": pairs,
        "allTimeHighUSD": allTimeHighUSD,
        "circulatingSupply": circulatingSupply,
        "maxSupply": maxSupply,
        "code": code,
        "rate": rate,
        "volume": volume,
        "cap": cap,
        "categories": categories,
        "delta": delta?.toJson(),
      };
}
