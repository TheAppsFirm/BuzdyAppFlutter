// To parse this JSON data, do
//
//     final merchantModel = merchantModelFromJson(jsonString);

import 'dart:convert';

MerchantModel merchantModelFromJson(String str) =>
    MerchantModel.fromJson(json.decode(str));

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

  MerchantModel copyWith({
    int? status,
    String? message,
    List<MerchantModelData>? merchants,
    Pagination? pagination,
  }) =>
      MerchantModel(
        status: status ?? this.status,
        message: message ?? this.message,
        merchants: merchants ?? this.merchants,
        pagination: pagination ?? this.pagination,
      );

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        status: json["status"],
        message: json["message"],
        merchants: List<MerchantModelData>.from(
            json["merchants"].map((x) => MerchantModelData.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
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
  final String slug;
  final String headline;
  final String email;
  final String password;
  final dynamic description;
  final String phone;
  final String phoneCountryCode;
  final String image;
  final String country;
  final String countryCode;
  final String city;
  final String timezone;
  final String latitude;
  final String longitude;
  final String address;
  final int featured;
  final String playStore;
  final String appStore;
  final String facebook;
  final String twitter;
  final String instagram;
  final String websiteUrl;
  final String advertisementUrl;
  final int isArchive;
  final int avgRating;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String merchants;
  final dynamic placeid;

  MerchantModelData({
    required this.id,
    required this.managerId,
    required this.name,
    required this.slug,
    required this.headline,
    required this.email,
    required this.password,
    required this.description,
    required this.phone,
    required this.phoneCountryCode,
    required this.image,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.timezone,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.featured,
    required this.playStore,
    required this.appStore,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.websiteUrl,
    required this.advertisementUrl,
    required this.isArchive,
    required this.avgRating,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.merchants,
    required this.placeid,
  });

  MerchantModelData copyWith({
    int? id,
    int? managerId,
    String? name,
    String? slug,
    String? headline,
    String? email,
    String? password,
    dynamic description,
    String? phone,
    String? phoneCountryCode,
    String? image,
    String? country,
    String? countryCode,
    String? city,
    String? timezone,
    String? latitude,
    String? longitude,
    String? address,
    int? featured,
    String? playStore,
    String? appStore,
    String? facebook,
    String? twitter,
    String? instagram,
    String? websiteUrl,
    String? advertisementUrl,
    int? isArchive,
    int? avgRating,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? merchants,
    dynamic placeid,
  }) =>
      MerchantModelData(
        id: id ?? this.id,
        managerId: managerId ?? this.managerId,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        headline: headline ?? this.headline,
        email: email ?? this.email,
        password: password ?? this.password,
        description: description ?? this.description,
        phone: phone ?? this.phone,
        phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
        image: image ?? this.image,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        city: city ?? this.city,
        timezone: timezone ?? this.timezone,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        featured: featured ?? this.featured,
        playStore: playStore ?? this.playStore,
        appStore: appStore ?? this.appStore,
        facebook: facebook ?? this.facebook,
        twitter: twitter ?? this.twitter,
        instagram: instagram ?? this.instagram,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        advertisementUrl: advertisementUrl ?? this.advertisementUrl,
        isArchive: isArchive ?? this.isArchive,
        avgRating: avgRating ?? this.avgRating,
        categoryId: categoryId ?? this.categoryId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        merchants: merchants ?? this.merchants,
        placeid: placeid ?? this.placeid,
      );

  factory MerchantModelData.fromJson(Map<String, dynamic> json) =>
      MerchantModelData(
        id: json["id"],
        managerId: json["manager_id"],
        name: json["name"],
        slug: json["slug"],
        headline: json["headline"],
        email: json["email"],
        password: json["password"],
        description: json["description"],
        phone: json["phone"] ?? "",
        phoneCountryCode: json["phone_country_code"],
        image: json["image"],
        country: json["country"] ?? "",
        countryCode: json["country_code"] ?? "",
        city: json["city"] ?? "",
        timezone: json["timezone"] ?? "",
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        featured: json["featured"],
        playStore: json["play_store"],
        appStore: json["app_store"],
        facebook: json["facebook"],
        twitter: json["twitter"],
        instagram: json["instagram"],
        websiteUrl: json["website_url"],
        advertisementUrl: json["advertisement_url"],
        isArchive: json["is_archive"],
        avgRating: json["avg_rating"],
        categoryId: json["category_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        merchants: json["merchants"],
        placeid: json["placeid"],
      );

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
  final int total;
  final int totalPages;

  Pagination({
    required this.pageNo,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  Pagination copyWith({
    int? pageNo,
    int? pageSize,
    int? total,
    int? totalPages,
  }) =>
      Pagination(
        pageNo: pageNo ?? this.pageNo,
        pageSize: pageSize ?? this.pageSize,
        total: total ?? this.total,
        totalPages: totalPages ?? this.totalPages,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        pageNo: json["page_no"],
        pageSize: json["page_size"],
        total: json["total"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "page_no": pageNo,
        "page_size": pageSize,
        "total": total,
        "totalPages": totalPages,
      };
}
