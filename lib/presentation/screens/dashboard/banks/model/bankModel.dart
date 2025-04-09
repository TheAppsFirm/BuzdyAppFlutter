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
        message: json["message"] ?? "No message",
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
  final String slug;
  final String name;
  final String email;
  final String phone;
  final String phoneCountryCode;
  final dynamic website;
  final String? advertisementUrl;
  final int advertisementState;
  final String country;
  final String countryCode;
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

  factory Bank.fromJson(Map<String, dynamic> json) {
    print("Parsing bank: ${json["name"]}");
    return Bank(
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      name: json["name"] ?? "Unknown Bank",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      phoneCountryCode: json["phone_country_code"] ?? "",
      website: json["website"],
      advertisementUrl: json["advertisement_url"],
      advertisementState: json["advertisement_state"] ?? 0,
      country: json["country"] ?? "",
      countryCode: json["country_code"] ?? "",
      city: json["city"] ?? "",
      timezone: json["timezone"] ?? "",
      latitude: json["latitude"] ?? "",
      longitude: json["longitude"] ?? "",
      avgRating: json["avg_rating"] ?? 0,
      isArchive: json["is_archive"] ?? 0,
      address: json["address"] ?? "",
      image: json["image"]?.contains('http') == true
          ? json["image"]
          : 'https://portal.buzdy.com/storage/admin/uploads/images/${json["image"] ?? "default.jpg"}',
      featured: json["featured"] ?? 0,
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
      playStore: json["play_store"] ?? "",
      appStore: json["app_store"] ?? "",
      facebook: json["facebook"] ?? "",
      twitter: json["twitter"] ?? "",
      instagram: json["instagram"] ?? "",
      branches: json["branches"] != null
          ? List<Branch>.from((json["branches"] as List<dynamic>).map((x) {
              try {
                return Branch.fromJson(x);
              } catch (e) {
                print("Error parsing branch: $e, Branch JSON: $x");
                return Branch(
                  name: "Unknown Branch",
                  email: "",
                  phone: "",
                  phoneCountryCode: "",
                  advertisementUrl: null,
                  advertisementState: 0,
                  fax: null,
                  country: "",
                  city: "",
                  timezone: "",
                  latitude: "",
                  longitude: "",
                  isArchive: 0,
                  branchCode: "",
                  managerName: null,
                  managerPhone: null,
                  managerEmail: null,
                  address: "",
                  id: 0,
                  bankCountryId: 0,
                  atmOnSite: 0,
                  atmOffSite: null,
                  fxBranch: 0,
                  image: "default.jpg",
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  bankSubadminId: null,
                  bankcountryadminId: null,
                  branchSubadminId: null,
                  bankId: json["id"] ?? 0,
                  featured: 0,
                  playStore: "",
                  appStore: "",
                  facebook: "",
                  twitter: "",
                  instagram: "",
                  avgRating: 0,
                  itemType: ItemType.BRANCHES,
                  placeid: null,
                  updatedName: 0,
                );
              }
            }))
          : [],
      reviews: json["reviews"] != null ? List<dynamic>.from(json["reviews"].map((x) => x)) : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
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
        "branches": List<dynamic>.from(branches.map((x) => x.toJson())),
        "reviews": List<dynamic>.from(reviews.map((x) => x)),
      };
}

class Branch {
  final String name;
  final String email;
  final String phone;
  final String phoneCountryCode;
  final dynamic advertisementUrl;
  final int advertisementState;
  final dynamic fax;
  final String country;
  final String city;
  final String timezone;
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
  final String appStore;
  final String facebook;
  final String twitter;
  final String instagram;
  final int avgRating;
  final ItemType itemType;
  final String? placeid;
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
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        phoneCountryCode: json["phone_country_code"] ?? "",
        advertisementUrl: json["advertisement_url"],
        advertisementState: json["advertisement_state"] ?? 0,
        fax: json["fax"],
        country: json["country"] ?? "",
        city: json["city"] ?? "",
        timezone: json["timezone"] ?? "",
        latitude: json["latitude"] ?? "",
        longitude: json["longitude"] ?? "",
        isArchive: json["is_archive"] ?? 0,
        branchCode: json["branch_code"] ?? "",
        managerName: json["manager_name"],
        managerPhone: json["manager_phone"],
        managerEmail: json["manager_email"],
        address: json["address"] ?? "",
        id: json["id"] ?? 0,
        bankCountryId: json["bank_country_id"] ?? 0,
        atmOnSite: json["atm_on_site"] ?? 0,
        atmOffSite: json["atm_off_site"],
        fxBranch: json["fx_branch"] ?? 0,
        image: json["image"]?.contains('http') == true
            ? json["image"]
            : 'https://portal.buzdy.com/storage/admin/uploads/images/${json["image"] ?? "default.jpg"}',
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
        bankSubadminId: json["bank_subadmin_id"],
        bankcountryadminId: json["bankcountryadmin_id"],
        branchSubadminId: json["branch_subadmin_id"],
        bankId: json["bank_id"] ?? 0,
        featured: json["featured"] ?? 0,
        playStore: json["play_store"] ?? "",
        appStore: json["app_store"] ?? "",
        facebook: json["facebook"] ?? "",
        twitter: json["twitter"] ?? "",
        instagram: json["instagram"] ?? "",
        avgRating: json["avg_rating"] ?? 0,
        itemType: itemTypeValues.map[json["item_type"]] ?? ItemType.BRANCHES,
        placeid: json["placeid"],
        updatedName: json["updated_name"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
        "phone_country_code": phoneCountryCode,
        "advertisement_url": advertisementUrl,
        "advertisement_state": advertisementState,
        "fax": fax,
        "country": country,
        "city": city,
        "timezone": timezone,
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
        "app_store": appStore,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
        "avg_rating": avgRating,
        "item_type": itemTypeValues.reverse[itemType],
        "placeid": placeid,
        "updated_name": updatedName,
      };
}

enum ItemType { BRANCHES }

final itemTypeValues = EnumValues({"branches": ItemType.BRANCHES});

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
        pageNo: json["page_no"] ?? 1,
        pageSize: json["page_size"] ?? 10,
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