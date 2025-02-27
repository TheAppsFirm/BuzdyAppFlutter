import 'dart:convert';

RugCheckModel rugCheckModelFromJson(String str) =>
    RugCheckModel.fromJson(json.decode(str));

String rugCheckModelToJson(RugCheckModel data) => json.encode(data.toJson());

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
        message: json["message"] ?? "No message available",
        data: json["data"] != null
            ? RugCheckModelData.fromJson(json["data"])
            : null,
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
  final InvestmentRanking? investmentRanking;
  final ExternalLinks? externalLinks;
  final Details? details;

  RugCheckModelData({
    required this.safe,
    required this.message,
    required this.riskLevel,
    this.investmentRanking,
    this.externalLinks,
    this.details,
  });

  factory RugCheckModelData.fromJson(Map<String, dynamic> json) =>
      RugCheckModelData(
        safe: json["safe"] ?? false,
        message: json["message"] ?? "No message available",
        riskLevel: json["riskLevel"] ?? "Unknown",
        investmentRanking: json["investmentRanking"] != null
            ? InvestmentRanking.fromJson(json["investmentRanking"])
            : null,
        externalLinks: json["externalLinks"] != null
            ? ExternalLinks.fromJson(json["externalLinks"])
            : null,
        details:
            json["details"] != null ? Details.fromJson(json["details"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "safe": safe,
        "message": message,
        "riskLevel": riskLevel,
        "investmentRanking": investmentRanking?.toJson(),
        "externalLinks": externalLinks?.toJson(),
        "details": details?.toJson(),
      };
}

class Details {
  final MintInfo? mintInfo;
  final double computedSupply;
  final AccountDetails? accountDetails;
  final dynamic tokenMetadata;
  final dynamic offChainMetadata;
  final LiquidityPool? liquidityPool;
  final Tokenomics? tokenomics;
  final List<String>? holderAnalysis;
  final String? topHolder;

  Details({
    this.mintInfo,
    required this.computedSupply,
    this.accountDetails,
    this.tokenMetadata,
    this.offChainMetadata,
    this.liquidityPool,
    this.tokenomics,
    this.holderAnalysis,
    this.topHolder,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        mintInfo: json["mintInfo"] != null
            ? MintInfo.fromJson(json["mintInfo"])
            : null,
        computedSupply: (json["computedSupply"] ?? 0.0).toDouble(),
        accountDetails: json["accountDetails"] != null
            ? AccountDetails.fromJson(json["accountDetails"])
            : null,
        tokenMetadata: json["tokenMetadata"],
        offChainMetadata: json["offChainMetadata"],
        liquidityPool: json["liquidityPool"] != null
            ? LiquidityPool.fromJson(json["liquidityPool"])
            : null,
        tokenomics: json["tokenomics"] != null
            ? Tokenomics.fromJson(json["tokenomics"])
            : null,
        holderAnalysis: json["holderAnalysis"] != null
            ? List<String>.from(json["holderAnalysis"].map((x) => x))
            : [],
        topHolder: json["topHolder"] ?? "Unknown",
      );

  Map<String, dynamic> toJson() => {
        "mintInfo": mintInfo?.toJson(),
        "computedSupply": computedSupply,
        "accountDetails": accountDetails?.toJson(),
        "tokenMetadata": tokenMetadata,
        "offChainMetadata": offChainMetadata,
        "liquidityPool": liquidityPool?.toJson(),
        "tokenomics": tokenomics?.toJson(),
        "holderAnalysis": holderAnalysis != null
            ? List<dynamic>.from(holderAnalysis!.map((x) => x))
            : [],
        "topHolder": topHolder,
      };
}

class AccountDetails {
  final int lamports;
  final String owner;
  final bool executable;
  final double rentEpoch;

  AccountDetails({
    required this.lamports,
    required this.owner,
    required this.executable,
    required this.rentEpoch,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) => AccountDetails(
        lamports: json["lamports"] ?? 0,
        owner: json["owner"] ?? "Unknown",
        executable: json["executable"] ?? false,
        rentEpoch: (json["rentEpoch"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lamports": lamports,
        "owner": owner,
        "executable": executable,
        "rentEpoch": rentEpoch,
      };
}

class LiquidityPool {
  final String locked;
  final String lockDuration;
  final String poolSize;

  LiquidityPool({
    required this.locked,
    required this.lockDuration,
    required this.poolSize,
  });

  factory LiquidityPool.fromJson(Map<String, dynamic> json) => LiquidityPool(
        locked: json["locked"] ?? "N/A",
        lockDuration: json["lockDuration"] ?? "N/A",
        poolSize: json["poolSize"] ?? "N/A",
      );

  Map<String, dynamic> toJson() => {
        "locked": locked,
        "lockDuration": lockDuration,
        "poolSize": poolSize,
      };
}

class MintInfo {
  final int decimals;
  final dynamic freezeAuthority;
  final bool isInitialized;
  final dynamic mintAuthority;
  final String supply;

  MintInfo({
    required this.decimals,
    this.freezeAuthority,
    required this.isInitialized,
    this.mintAuthority,
    required this.supply,
  });

  factory MintInfo.fromJson(Map<String, dynamic> json) => MintInfo(
        decimals: json["decimals"] ?? 0,
        freezeAuthority: json["freezeAuthority"],
        isInitialized: json["isInitialized"] ?? false,
        mintAuthority: json["mintAuthority"],
        supply: json["supply"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "decimals": decimals,
        "freezeAuthority": freezeAuthority,
        "isInitialized": isInitialized,
        "mintAuthority": mintAuthority,
        "supply": supply,
      };
}

class Tokenomics {
  final String vesting;
  final double maxSupply;

  Tokenomics({
    required this.vesting,
    required this.maxSupply,
  });

  factory Tokenomics.fromJson(Map<String, dynamic> json) => Tokenomics(
        vesting: json["vesting"] ?? "Unknown",
        maxSupply: (json["maxSupply"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "vesting": vesting,
        "maxSupply": maxSupply,
      };
}

class ExternalLinks {
  final String explorer;
  final String solanabeach;
  final String raydium;

  ExternalLinks({
    required this.explorer,
    required this.solanabeach,
    required this.raydium,
  });

  factory ExternalLinks.fromJson(Map<String, dynamic> json) => ExternalLinks(
        explorer: json["explorer"] ?? "",
        solanabeach: json["solanabeach"] ?? "",
        raydium: json["raydium"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "explorer": explorer,
        "solanabeach": solanabeach,
        "raydium": raydium,
      };
}

class InvestmentRanking {
  final int score;
  final String recommendation;

  InvestmentRanking({
    required this.score,
    required this.recommendation,
  });

  factory InvestmentRanking.fromJson(Map<String, dynamic> json) =>
      InvestmentRanking(
        score: json["score"] ?? 0,
        recommendation: json["recommendation"] ?? "No recommendation",
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "recommendation": recommendation,
      };
}
