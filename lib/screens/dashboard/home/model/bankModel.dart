// To parse this JSON data, do
//
//     final bankModel = bankModelFromJson(jsonString);

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
        status: json["status"],
        message: json["message"],
        banks: List<Bank>.from(json["banks"].map((x) => Bank.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
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
  final String slug;
  final String name;
  final String email;
  final String phone;
  final CountryCode phoneCountryCode;
  final dynamic website;
  final String? advertisementUrl;
  final int advertisementState;
  final Country country;
  final CountryCode countryCode;
  final String city;
  final String timezone;
  final String latitude;
  final String longitude;
  final int avgRating;
  final int isArchive;
  final String address;
  final String image;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String playStore;
  final String appStore;
  final String facebook;
  final String twitter;
  final String instagram;
  final List<Branch> branches;
  final List<dynamic> reviews;

  Bank({
    required this.id,
    required this.slug,
    required this.name,
    required this.email,
    required this.phone,
    required this.phoneCountryCode,
    required this.website,
    required this.advertisementUrl,
    required this.advertisementState,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.timezone,
    required this.latitude,
    required this.longitude,
    required this.avgRating,
    required this.isArchive,
    required this.address,
    required this.image,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    required this.playStore,
    required this.appStore,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.branches,
    required this.reviews,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        phoneCountryCode: countryCodeValues.map[json["phone_country_code"]]!,
        website: json["website"] ?? "",
        advertisementUrl: json["advertisement_url"],
        advertisementState: json["advertisement_state"],
        country: countryValues.map[json["country"]]!,
        countryCode: countryCodeValues.map[json["country_code"]]!,
        city: json["city"],
        timezone: json["timezone"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        avgRating: json["avg_rating"],
        isArchive: json["is_archive"],
        address: json["address"],
        image: json["image"],
        featured: json["featured"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        playStore: json["play_store"] ?? "",
        appStore: json["app_store"] ?? "",
        facebook: json["facebook"] ?? "",
        twitter: json["twitter"] ?? "",
        instagram: json["instagram"] ?? "",
        branches:
            List<Branch>.from(json["branches"].map((x) => Branch.fromJson(x))),
        reviews: List<dynamic>.from(json["reviews"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "email": email,
        "phone": phone,
        "phone_country_code": countryCodeValues.reverse[phoneCountryCode],
        "website": website,
        "advertisement_url": advertisementUrl,
        "advertisement_state": advertisementState,
        "country": countryValues.reverse[country],
        "country_code": countryCodeValues.reverse[countryCode],
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
        "branches": List<dynamic>.from(branches.map((x) => x.toJson())),
        "reviews": List<dynamic>.from(reviews.map((x) => x)),
      };
}

class Branch {
  final String name;
  final Email email;
  final String phone;
  final CountryCode phoneCountryCode;
  final dynamic advertisementUrl;
  final int advertisementState;
  final dynamic fax;
  final Country country;
  final City city;
  final Timezone timezone;
  final String latitude;
  final String longitude;
  final int isArchive;
  final String branchCode;
  final dynamic managerName;
  final dynamic managerPhone;
  final dynamic managerEmail;
  final String address;
  final int id;
  final int bankCountryId;
  final int atmOnSite;
  final dynamic atmOffSite;
  final int fxBranch;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic bankSubadminId;
  final dynamic bankcountryadminId;
  final dynamic branchSubadminId;
  final int bankId;
  final int featured;
  final String playStore;
  final AppStore appStore;
  final Facebook facebook;
  final Twitter twitter;
  final Instagram instagram;
  final int avgRating;
  final ItemType itemType;
  final String placeid;
  final int updatedName;

  Branch({
    required this.name,
    required this.email,
    required this.phone,
    required this.phoneCountryCode,
    required this.advertisementUrl,
    required this.advertisementState,
    required this.fax,
    required this.country,
    required this.city,
    required this.timezone,
    required this.latitude,
    required this.longitude,
    required this.isArchive,
    required this.branchCode,
    required this.managerName,
    required this.managerPhone,
    required this.managerEmail,
    required this.address,
    required this.id,
    required this.bankCountryId,
    required this.atmOnSite,
    required this.atmOffSite,
    required this.fxBranch,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.bankSubadminId,
    required this.bankcountryadminId,
    required this.branchSubadminId,
    required this.bankId,
    required this.featured,
    required this.playStore,
    required this.appStore,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.avgRating,
    required this.itemType,
    required this.placeid,
    required this.updatedName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        name: json["name"],
        email: emailValues.map[json["email"]]!,
        phone: json["phone"],
        phoneCountryCode: countryCodeValues.map[json["phone_country_code"]]!,
        advertisementUrl: json["advertisement_url"] ?? "",
        advertisementState: json["advertisement_state"],
        fax: json["fax"] ?? "",
        country: countryValues.map[json["country"]]!,
        city: cityValues.map[json["city"]]!,
        timezone: timezoneValues.map[json["timezone"]]!,
        latitude: json["latitude"],
        longitude: json["longitude"],
        isArchive: json["is_archive"],
        branchCode: json["branch_code"],
        managerName: json["manager_name"] ?? "",
        managerPhone: json["manager_phone"] ?? "",
        managerEmail: json["manager_email"] ?? "",
        address: json["address"],
        id: json["id"],
        bankCountryId: json["bank_country_id"],
        atmOnSite: json["atm_on_site"] ?? "",
        atmOffSite: json["atm_off_site"] ?? "",
        fxBranch: json["fx_branch"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        bankSubadminId: json["bank_subadmin_id"] ?? "",
        bankcountryadminId: json["bankcountryadmin_id"] ?? "",
        branchSubadminId: json["branch_subadmin_id"] ?? '',
        bankId: json["bank_id"],
        featured: json["featured"],
        playStore: json["play_store"],
        appStore: appStoreValues.map[json["app_store"]]!,
        facebook: facebookValues.map[json["facebook"]]!,
        twitter: twitterValues.map[json["twitter"]]!,
        instagram: instagramValues.map[json["instagram"]]!,
        avgRating: json["avg_rating"],
        itemType: itemTypeValues.map[json["item_type"]]!,
        placeid: json["placeid"],
        updatedName: json["updated_name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": emailValues.reverse[email],
        "phone": phone,
        "phone_country_code": countryCodeValues.reverse[phoneCountryCode],
        "advertisement_url": advertisementUrl,
        "advertisement_state": advertisementState,
        "fax": fax,
        "country": countryValues.reverse[country],
        "city": cityValues.reverse[city],
        "timezone": timezoneValues.reverse[timezone],
        "latitude": latitude,
        "longitude": longitude,
        "is_archive": isArchive,
        "branch_code": branchCode,
        "manager_name": managerName,
        "manager_phone": managerPhone,
        "manager_email": managerEmail,
        "address": address,
        "id": id,
        "bank_country_id": bankCountryId,
        "atm_on_site": atmOnSite,
        "atm_off_site": atmOffSite,
        "fx_branch": fxBranch,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "bank_subadmin_id": bankSubadminId,
        "bankcountryadmin_id": bankcountryadminId,
        "branch_subadmin_id": branchSubadminId,
        "bank_id": bankId,
        "featured": featured,
        "play_store": playStore,
        "app_store": appStoreValues.reverse[appStore],
        "facebook": facebookValues.reverse[facebook],
        "twitter": twitterValues.reverse[twitter],
        "instagram": instagramValues.reverse[instagram],
        "avg_rating": avgRating,
        "item_type": itemTypeValues.reverse[itemType],
        "placeid": placeid,
        "updated_name": updatedName,
      };
}

enum AppStore { APPS_APPLE_COM_US_APP_MCBLIVE_ID1584933248 }

final appStoreValues = EnumValues({
  "apps.apple.com/us/app/mcblive/id1584933248":
      AppStore.APPS_APPLE_COM_US_APP_MCBLIVE_ID1584933248
});

enum City { LAHORE }

final cityValues = EnumValues({"Lahore": City.LAHORE});

enum Country { PAKISTAN }

final countryValues = EnumValues({"Pakistan": Country.PAKISTAN});

enum Email { MCB_GMAIL_COM }

final emailValues = EnumValues({"mcb@gmail.com": Email.MCB_GMAIL_COM});

enum Facebook { WWW_FACEBOOK_COM_MCB_BANK_PK }

final facebookValues = EnumValues(
    {"www.facebook.com/MCBBankPk": Facebook.WWW_FACEBOOK_COM_MCB_BANK_PK});

enum Instagram { WWW_INSTAGRAM_COM }

final instagramValues =
    EnumValues({"www.instagram.com": Instagram.WWW_INSTAGRAM_COM});

enum ItemType { BRANCHES }

final itemTypeValues = EnumValues({"branches": ItemType.BRANCHES});

enum CountryCode { PK }

final countryCodeValues = EnumValues({"pk": CountryCode.PK});

enum Timezone { GMT_5 }

final timezoneValues = EnumValues({"GMT+5": Timezone.GMT_5});

enum Twitter { TWITTER_COM_MCB_BANK_PK }

final twitterValues =
    EnumValues({"twitter.com/MCBBankPk": Twitter.TWITTER_COM_MCB_BANK_PK});

class Pagination {
  final int pageNo;
  final int pageSize;
  final int? total;
  final int? totalPages;

  Pagination({
    required this.pageNo,
    this.pageSize = 10,
    this.total,
    this.totalPages,
  });

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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
