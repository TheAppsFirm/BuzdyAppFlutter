import 'dart:convert';

MerchantModel merchantModelFromJson(String str) => MerchantModel.fromJson(json.decode(str));

String merchantModelToJson(MerchantModel data) => json.encode(data.toJson());

class MerchantModel {
  final int status;
  final String message;
  final List<MerchantModelData> merchants;
  final Pagination pagination;

  MerchantModel({
    required this.status,
    required this.message,
    required this.merchants,
    required this.pagination,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        status: json["status"] ?? 0,
        message: json["message"] ?? json["msg"] ?? "No message",
        merchants: List<MerchantModelData>.from(
            (json["merchants"] ?? []).map((x) => MerchantModelData.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"] ?? {"page_no": 1, "page_size": 10, "total": 0, "totalPages": 1}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "merchants": List<dynamic>.from(merchants.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
      };
}

class MerchantModelData {
  final int id;
  final int managerId;
  final String name;
  final String? slug;
  final String? headline;
  final String? email;
  final String? password;
  final String? description;
  final String? phone;
  final String? phoneCountryCode;
  final String? image;
  final String? country;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String? latitude;
  final String? longitude;
  final String? address;
  final int featured;
  final String? playStore;
  final String? appStore;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? websiteUrl;
  final String? advertisementUrl;
  final int isArchive;
  final int avgRating;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? merchants;
  final String? placeid;

  MerchantModelData({
    required this.id,
    required this.managerId,
    required this.name,
    this.slug,
    this.headline,
    this.email,
    this.password,
    this.description,
    this.phone,
    this.phoneCountryCode,
    this.image,
    this.country,
    this.countryCode,
    this.city,
    this.timezone,
    this.latitude,
    this.longitude,
    this.address,
    required this.featured,
    this.playStore,
    this.appStore,
    this.facebook,
    this.twitter,
    this.instagram,
    this.websiteUrl,
    this.advertisementUrl,
    required this.isArchive,
    required this.avgRating,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.merchants,
    this.placeid,
  });

  factory MerchantModelData.fromJson(Map<String, dynamic> json) {
    final imageUrl = json["image"] != null
        ? (json["image"].contains('http')
            ? json["image"]
            : 'https://portal.buzdy.com/storage/admin/uploads/images/${json["image"]}')
        : null;
    print("Constructed Merchant Image URL: $imageUrl"); // Log the constructed URL
    return MerchantModelData(
      id: json["id"] ?? 0,
      managerId: json["manager_id"] ?? 0,
      name: json["name"] ?? "Unknown Merchant",
      slug: json["slug"],
      headline: json["headline"],
      email: json["email"],
      password: json["password"],
      description: json["description"],
      phone: json["phone"],
      phoneCountryCode: json["phone_country_code"],
      image: imageUrl,
      country: json["country"],
      countryCode: json["country_code"],
      city: json["city"],
      timezone: json["timezone"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      address: json["address"],
      featured: json["featured"] ?? 0,
      playStore: json["play_store"],
      appStore: json["app_store"],
      facebook: json["facebook"],
      twitter: json["twitter"],
      instagram: json["instagram"],
      websiteUrl: json["website_url"],
      advertisementUrl: json["advertisement_url"],
      isArchive: json["is_archive"] ?? 0,
      avgRating: json["avg_rating"] ?? 0,
      categoryId: json["category_id"] ?? 0,
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
      merchants: json["merchants"],
      placeid: json["placeid"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "manager_id": managerId,
        "name": name,
        "slug": slug,
        "headline": headline,
        "email": email,
        "password": password,
        "description": description,
        "phone": phone,
        "phone_country_code": phoneCountryCode,
        "image": image,
        "country": country,
        "country_code": countryCode,
        "city": city,
        "timezone": timezone,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "featured": featured,
        "play_store": playStore,
        "app_store": appStore,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
        "website_url": websiteUrl,
        "advertisement_url": advertisementUrl,
        "is_archive": isArchive,
        "avg_rating": avgRating,
        "category_id": categoryId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "merchants": merchants,
        "placeid": placeid,
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