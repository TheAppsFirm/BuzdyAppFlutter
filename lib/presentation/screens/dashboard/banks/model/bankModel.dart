import 'dart:convert';

BankModel bankModelFromJson(String str) => BankModel.fromJson(json.decode(str));

String bankModelToJson(BankModel data) => json.encode(data.toJson());

class BankModel {
  final int status;
  final String message;
  final List<Bank> banks;
  final Pagination pagination;

  BankModel({
    required this.status,
    required this.message,
    required this.banks,
    required this.pagination,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
        status: json["status"] ?? 0,
        message: json["message"] ?? json["msg"] ?? "No message",
        banks: List<Bank>.from((json["banks"] ?? []).map((x) => Bank.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"] ?? {"page_no": 1, "page_size": 10, "total": 0, "totalPages": 1}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "banks": List<dynamic>.from(banks.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
      };
}

class Bank {
  final int id;
  final String name;
  final String? slug;
  final String? email;
  final String? phone;
  final String? phoneCountryCode;
  final String? website;
  final String? advertisementUrl;
  final int advertisementState;
  final String? country;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String? latitude;
  final String? longitude;
  final int avgRating;
  final int isArchive;
  final String? address;
  final String? image;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? playStore;
  final String? appStore;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final List<dynamic> reviews; // Assuming reviews is a list, adjust if needed

  Bank({
    required this.id,
    required this.name,
    this.slug,
    this.email,
    this.phone,
    this.phoneCountryCode,
    this.website,
    this.advertisementUrl,
    required this.advertisementState,
    this.country,
    this.countryCode,
    this.city,
    this.timezone,
    this.latitude,
    this.longitude,
    required this.avgRating,
    required this.isArchive,
    this.address,
    this.image,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.playStore,
    this.appStore,
    this.facebook,
    this.twitter,
    this.instagram,
    required this.reviews,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    final imageUrl = json["image"] != null
        ? (json["image"].contains('http')
            ? json["image"]
            : 'https://portal.buzdy.com/storage/admin/uploads/images/${json["image"]}')
        : null;
    print("Constructed Bank Image URL: $imageUrl"); // Log the constructed URL
    return Bank(
      id: json["id"] ?? 0,
      name: json["name"] ?? "Unknown Bank",
      slug: json["slug"],
      email: json["email"],
      phone: json["phone"],
      phoneCountryCode: json["phone_country_code"],
      website: json["website"],
      advertisementUrl: json["advertisement_url"],
      advertisementState: json["advertisement_state"] ?? 0,
      country: json["country"],
      countryCode: json["country_code"],
      city: json["city"],
      timezone: json["timezone"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      avgRating: json["avg_rating"] ?? 0,
      isArchive: json["is_archive"] ?? 0,
      address: json["address"],
      image: imageUrl,
      featured: json["featured"] ?? 0,
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
      playStore: json["play_store"],
      appStore: json["app_store"],
      facebook: json["facebook"],
      twitter: json["twitter"],
      instagram: json["instagram"],
      reviews: json["reviews"] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "email": email,
        "phone": phone,
        "phone_country_code": phoneCountryCode,
        "website": website,
        "advertisement_url": advertisementUrl,
        "advertisement_state": advertisementState,
        "country": country,
        "country_code": countryCode,
        "city": city,
        "timezone": timezone,
        "latitude": latitude,
        "longitude": longitude,
        "avg_rating": avgRating,
        "is_archive": isArchive,
        "address": address,
        "image": image,
        "featured": featured,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "play_store": playStore,
        "app_store": appStore,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
        "reviews": reviews,
      };
}

class Pagination {
  final int pageNo;
  final int pageSize;
  final int? total;
  final int totalPages;

  Pagination({
    required this.pageNo,
    this.pageSize = 10,
    this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        pageNo: json["page_no"] ?? 1,
        pageSize: json["page_size"] ?? 10,
        total: json["total"],
        totalPages: json["totalPages"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "page_no": pageNo,
        "page_size": pageSize,
        "total": total,
        "totalPages": totalPages,
      };
}