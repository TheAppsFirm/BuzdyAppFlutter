import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));
String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  final int status;
  final String message;
  final List<Product>? products;
  final Pagination pagination;

  ProductModel({
    required this.status,
    required this.message,
    this.products,
    required this.pagination,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json["products"];
    final productsList = rawProducts != null && rawProducts is List
        ? List<Product>.from(rawProducts.map((x) => Product.fromJson(x as Map<String, dynamic>)))
        : <Product>[]; // Empty list if null or not a list
    return ProductModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? json["msg"] ?? "No message",
      products: productsList,
      pagination: Pagination.fromJson(json["pagination"] ?? {
        "page_no": json["page_no"] ?? 1,
        "page_size": json["page_size"] ?? 10,
        "total": productsList.length,
        "totalPages": json["pagination"] != null
            ? (json["pagination"]["totalPages"] ?? 1)
            : productsList.length == 10 ? 2 : 1,
      }),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "products": products != null
            ? List<dynamic>.from(products!.map((x) => x.toJson()))
            : [],
        "pagination": pagination.toJson(),
      };
}

class Product {
  final int id;
  final String slug;
  final String name;
  final String description;
  final String? image;
  final int featured;
  final String productableType;
  final int productableId;
  final int? bankId;
  final int avgRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int categoryId;
  final int isArchive;
  final String phone;
  final String phoneCountryCode;
  final String itemType;

  Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    this.image,
    required this.featured,
    required this.productableType,
    required this.productableId,
    this.bankId,
    required this.avgRating,
    this.createdAt,
    this.updatedAt,
    required this.categoryId,
    required this.isArchive,
    required this.phone,
    required this.phoneCountryCode,
    required this.itemType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageUrl = json["image"] != null
        ? (json["image"].toString().contains('http')
            ? json["image"]
            : 'https://portal.buzdy.com/storage/admin/uploads/images/${json["image"]}')
        : null;
    print("Constructed Product Image URL: $imageUrl");
    return Product(
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      name: json["name"] ?? "Unknown Product",
      description: json["description"] ?? "No description available",
      image: imageUrl,
      featured: json["featured"] ?? 0,
      productableType: json["productable_type"] ?? "",
      productableId: json["productable_id"] ?? 0,
      bankId: json["bank_id"],
      avgRating: json["avg_rating"] ?? 0,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"]) ?? DateTime.now()
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"]) ?? DateTime.now()
          : null,
      categoryId: json["category_id"] ?? 0,
      isArchive: json["is_archive"] ?? 0,
      phone: json["phone"] ?? "N/A",
      phoneCountryCode: json["phone_country_code"] ?? "N/A",
      itemType: json["item_type"] ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "description": description,
        "image": image,
        "featured": featured,
        "productable_type": productableType,
        "productable_id": productableId,
        "bank_id": bankId,
        "avg_rating": avgRating,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "category_id": categoryId,
        "is_archive": isArchive,
        "phone": phone,
        "phone_country_code": phoneCountryCode,
        "item_type": itemType,
      };
}

class Pagination {
  final int pageNo;
  final int pageSize;
  final int? total;
  final int totalPages;

  Pagination({
    required this.pageNo,
    required this.pageSize,
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