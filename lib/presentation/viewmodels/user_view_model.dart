import 'dart:convert';
import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/presentation/dashboard/dashboard_screen.dart';
import 'package:buzdy/presentation/screens/dashboard/products/model/productModel.dart';
import 'package:buzdy/repository/auth_api/auth_http_api_repository.dart';
import 'package:buzdy/response/api_response.dart';
import 'package:buzdy/response/status.dart';
import 'package:buzdy/presentation/screens/auth/model/userModel.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/coinModel.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/rugcheckModel.dart';
import 'package:buzdy/presentation/screens/dashboard/feed/model/youtubeModel.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/model/bankModel.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/model/merchnatModel.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> listCoins = [];
  List<Bank> bankList = [];
  int bankcurrentPage = 1;
  bool bankisLoadingMore = false;
  bool bankhasMoreData = true;

  List<MerchantModelData> merchantList = [];
  int merchantcurrentPage = 1;
  bool merchantisLoadingMore = false;
  bool merchanthasMoreData = true;

  List<Product> productList = [];
  int productcurrentPage = 1;
  bool productisLoadingMore = false;
  bool producthasMoreData = true;
  String? selectedType; // Moved from ProductsScreen

  UserModelData? userModel;
  List<BubbleCoinModel> bubbleCoins = [];

  UserViewModel() {
    resetFilters();
    getAllBanks(pageNumber: bankcurrentPage);
    getAllMarchants(pageNumber: merchantcurrentPage);
    getAllProducts(pageNumber: productcurrentPage); // Initial fetch
    fetchCoins(limit: 25);
    fetchBubbleCoins();
  }

  void resetFilters() {
    bankList.clear();
    bankcurrentPage = 1;
    bankisLoadingMore = false;
    bankhasMoreData = true;
    merchantList.clear();
    merchantcurrentPage = 1;
    merchantisLoadingMore = false;
    merchanthasMoreData = true;
    productList.clear();
    productcurrentPage = 1;
    productisLoadingMore = false;
    producthasMoreData = true;
    selectedType = null;
    notifyListeners();
  }

  void _logRequest(String method, String endpoint, {dynamic payload, Map<String, String>? params}) {
    print('=== REQUEST ===');
    print('Method: $method');
    print('Endpoint: $endpoint');
    if (params != null) print('Params: ${jsonEncode(params)}');
    if (payload != null) print('Payload: ${jsonEncode(payload)}');
    print('Timestamp: ${DateTime.now().toIso8601String()}');
  }

  void _logResponse(String endpoint, dynamic response, {int? statusCode}) {
    print('=== RESPONSE ===');
    print('Endpoint: $endpoint');
    print('Status Code: $statusCode');
    print('Response: ${response != null ? jsonEncode(response) : 'null'}');
    print('Timestamp: ${DateTime.now().toIso8601String()}');
    print('===============');
  }

  Future login({dynamic payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    _logRequest('POST', 'login', payload: payload);

    ApiResponse res = await repository.loginApi(payload);
    Responses ress = res.data;
    _logResponse('login', ress.data, statusCode: ress.status);

    if (ress.status == 1) {
      easyLoadingStop();
      UIHelper.showMySnak(title: "Buzdy", message: "Login successfully", isError: false);
      userModel = UserModelData.fromJson(ress.data);
      await savetoken(token: ress.data['token'].toString());
      await saveUserId(userId: ress.data['id'].toString());
      Get.offAll(() => DashboardScreen());
      notifyListeners();
    } else {
      easyLoadingStop();
      UIHelper.showMySnak(title: "ERROR", message: ress.message.toString(), isError: true);
    }
  }

  Future register({dynamic payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    _logRequest('POST', 'register', payload: payload);

    try {
      ApiResponse res = await repository.registerApi(payload);
      if (res.data == null) {
        easyLoadingStop();
        UIHelper.showMySnak(title: "ERROR", message: "Unexpected error. Please try again.", isError: true);
        return;
      }
      Responses ress = res.data;
      _logResponse('register', ress.data, statusCode: ress.status);

      if (ress.status == 1) {
        easyLoadingStop();
        UIHelper.showMySnak(title: "Buzdy", message: ress.message ?? "Signup successful", isError: false);
        userModel = UserModelData.fromJson(ress.data);
        await savetoken(token: ress.data['token'].toString());
        await saveUserId(userId: ress.data['id'].toString());
        Get.offAll(() => DashboardScreen());
        notifyListeners();
      } else {
        easyLoadingStop();
        UIHelper.showMySnak(title: "ERROR", message: ress.message ?? "Something went wrong", isError: true);
      }
    } catch (e) {
      easyLoadingStop();
      UIHelper.showMySnak(title: "ERROR", message: "An unexpected error occurred: $e", isError: true);
    }
  }

  Future getAllBanks({required int pageNumber}) async {
    if (!bankhasMoreData || bankisLoadingMore) return;

    bankisLoadingMore = true;
    notifyListeners();

    _logRequest('GET', 'getAllBanks', params: {'pageNumber': pageNumber.toString()});

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllBanks(PageNumber: pageNumber);

    if (res.status == Status.completed && res.data != null) {
      Responses ress = res.data;
      _logResponse('getAllBanks', ress.data, statusCode: ress.status);

      if (ress.status == 1 && ress.data != null) {
        try {
          BankModel model = BankModel.fromJson({
            "status": ress.status,
            "message": ress.message,
            "banks": ress.data,
            "pagination": ress.pagination ?? {
              "page_no": pageNumber,
              "page_size": 10,
              "total": ress.data.length,
              "totalPages": ress.data.isEmpty ? 1 : pageNumber + 1,
            },
          });

          bankList.addAll(model.banks);
          bankcurrentPage = model.pagination.pageNo + 1;
          bankhasMoreData = model.banks.isNotEmpty && model.pagination.pageNo < model.pagination.totalPages;
        } catch (e) {
          print("Error parsing BankModel: $e");
          UIHelper.showMySnak(title: "ERROR", message: "Failed to parse bank data: $e", isError: true);
          bankhasMoreData = false;
        }
      } else {
        UIHelper.showMySnak(title: "ERROR", message: ress.message ?? "No banks found", isError: true);
        bankhasMoreData = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message ?? "Failed to fetch banks", isError: true);
      bankhasMoreData = false;
    }

    bankisLoadingMore = false;
    notifyListeners();
  }

  Future getBanksByCountry({
    required String country,
    String? city,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    bankisLoadingMore = true;
    if (pageNumber == 1) {
      bankList.clear();
      bankcurrentPage = 1;
      bankhasMoreData = true;
    }
    notifyListeners();

    _logRequest('GET', 'getBanksByCountry', params: {
      'country': country,
      if (city != null) 'city': city,
      'page_no': pageNumber.toString(),
      'page_size': pageSize.toString(),
    });

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getBanksByCountry(
      country: country,
      city: city,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.status == Status.completed && res.data != null) {
      Responses ress = res.data;
      _logResponse('getBanksByCountry', ress.data, statusCode: ress.status);

      if (ress.status == 1 && ress.data != null) {
        try {
          BankModel model = BankModel.fromJson({
            "status": ress.status,
            "message": ress.message,
            "banks": ress.data,
            "pagination": ress.pagination ?? {
              "page_no": pageNumber,
              "page_size": pageSize,
              "total": ress.data.length,
              "totalPages": ress.data.isEmpty ? 1 : pageNumber + 1,
            },
          });
          bankList.addAll(model.banks);
          bankcurrentPage = pageNumber + 1;
          bankhasMoreData = model.banks.isNotEmpty && pageNumber < model.pagination.totalPages;
        } catch (e) {
          print("Error parsing BankModel for country filter: $e");
          UIHelper.showMySnak(title: "ERROR", message: "Failed to parse bank data: $e", isError: true);
          bankhasMoreData = false;
        }
      } else {
        UIHelper.showMySnak(title: "ERROR", message: ress.message ?? "No banks found", isError: true);
        bankhasMoreData = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message ?? "Failed to fetch banks", isError: true);
      bankhasMoreData = false;
    }

    bankisLoadingMore = false;
    notifyListeners();
  }

  Future getAllMarchants({required int pageNumber}) async {
    if (!merchanthasMoreData || merchantisLoadingMore) return;

    merchantisLoadingMore = true;
    notifyListeners();

    _logRequest('GET', 'getAllMerchants', params: {'pageNumber': pageNumber.toString()});

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllMerchants(PageNumber: pageNumber);

    if (res.status == Status.completed && res.data != null) {
      Responses ress = res.data;
      _logResponse('getAllMerchants', ress.data, statusCode: ress.status);

      if (ress.status == 1 && ress.data != null) {
        try {
          MerchantModel model = MerchantModel.fromJson({
            "status": ress.status,
            "message": ress.message,
            "merchants": ress.data,
            "pagination": ress.pagination ?? {
              "page_no": pageNumber,
              "page_size": 10,
              "total": ress.data.length,
              "totalPages": ress.data.isEmpty ? 1 : pageNumber + 1,
            },
          });

          merchantList.addAll(model.merchants);
          merchantcurrentPage = model.pagination.pageNo + 1;
          merchanthasMoreData = model.merchants.isNotEmpty && model.pagination.pageNo < model.pagination.totalPages;
        } catch (e) {
          print("Error parsing MerchantModel: $e");
          UIHelper.showMySnak(title: "ERROR", message: "Failed to parse merchant data: $e", isError: true);
          merchanthasMoreData = false;
        }
      } else {
        UIHelper.showMySnak(title: "ERROR", message: ress.message ?? "No merchants found", isError: true);
        merchanthasMoreData = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message ?? "Failed to fetch merchants", isError: true);
      merchanthasMoreData = false;
    }

    merchantisLoadingMore = false;
    notifyListeners();
  }

  Future getMerchantsByCountry({
    required String country,
    String? city,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    merchantisLoadingMore = true;
    if (pageNumber == 1) {
      merchantList.clear();
      merchantcurrentPage = 1;
      merchanthasMoreData = true;
    }
    notifyListeners();

    _logRequest('GET', 'getMerchantsByCountry', params: {
      'country': country,
      if (city != null) 'city': city,
      'page_no': pageNumber.toString(),
      'page_size': pageSize.toString(),
    });

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getMerchantsByCountry(
      country: country,
      city: city,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.status == Status.completed && res.data != null) {
      Responses ress = res.data;
      _logResponse('getMerchantsByCountry', ress.data, statusCode: ress.status);

      if (ress.status == 1 && ress.data != null) {
        try {
          MerchantModel model = MerchantModel.fromJson({
            "status": ress.status,
            "message": ress.message,
            "merchants": ress.data,
            "pagination": ress.pagination ?? {
              "page_no": pageNumber,
              "page_size": pageSize,
              "total": ress.data.length,
              "totalPages": ress.data.isEmpty ? 1 : pageNumber + 1,
            },
          });
          merchantList.addAll(model.merchants);
          merchantcurrentPage = pageNumber + 1;
          merchanthasMoreData = model.merchants.isNotEmpty && pageNumber < model.pagination.totalPages;
        } catch (e) {
          print("Error parsing MerchantModel for country filter: $e");
          UIHelper.showMySnak(title: "ERROR", message: "Failed to parse merchant data: $e", isError: true);
          merchanthasMoreData = false;
        }
      } else {
        UIHelper.showMySnak(title: "ERROR", message: ress.message ?? "No merchants found", isError: true);
        merchanthasMoreData = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message ?? "Failed to fetch merchants", isError: true);
      merchanthasMoreData = false;
    }

    merchantisLoadingMore = false;
    notifyListeners();
  }

 // Only showing the updated `getAllProducts` method for brevity. Replace this in your existing `UserViewModel` class.

Future getAllProducts({required int pageNumber, int retryCount = 0}) async {
  if (!producthasMoreData || productisLoadingMore) return;

  const maxRetries = 3;
  productisLoadingMore = true;
  notifyListeners();

  _logRequest('GET', 'getAllProducts', params: {'pageNumber': pageNumber.toString()});

  AuthHttpApiRepository repository = AuthHttpApiRepository();
  try {
    ApiResponse res = await repository.getAllProducts(PageNumber: pageNumber);
    print("API Response Status: ${res.status}, Message: ${res.message}, Data type: ${res.data.runtimeType}");

    if (res.status == Status.completed && res.data != null) {
      Map<String, dynamic> rawData;
      if (res.data is Responses) {
        Responses ress = res.data as Responses;
        rawData = {
          "status": ress.status,
          "message": ress.message,
          "products": ress.data,
        };
      } else if (res.data is Map<String, dynamic>) {
        rawData = res.data as Map<String, dynamic>;
      } else {
        throw Exception("Unexpected data type: ${res.data.runtimeType}");
      }

      _logResponse('getAllProducts', rawData, statusCode: rawData['status']);

      if (rawData['status'] == 1) {
        print("Parsing products from rawData: ${jsonEncode(rawData)}");
        ProductModel model = ProductModel.fromJson(rawData);

        print("Parsed ProductModel: status=${model.status}, products length=${model.products?.length ?? 0}");
        if (model.products != null && model.products!.isNotEmpty) {
          if (pageNumber == 1) {
            productList.clear();
          }
          productList.addAll(model.products!);
          productcurrentPage = pageNumber + 1;
          // Improved pagination logic
          if (model.pagination.total != null && model.pagination.totalPages != null) {
            producthasMoreData = model.pagination.pageNo < model.pagination.totalPages;
          } else {
            producthasMoreData = model.products!.length == 10; // Assume more if full page
            print("Warning: No pagination data from API, assuming hasMoreData: $producthasMoreData");
          }
          print("Total products loaded: ${productList.length}, Has more: $producthasMoreData");
        } else {
          producthasMoreData = false;
          print("No products available in response (products list is empty or null).");
          UIHelper.showMySnak(
            title: "INFO",
            message: "No products found for this request.",
            isError: false,
          );
        }
      } else {
        print("API status not successful: ${rawData['message']}");
        UIHelper.showMySnak(title: "ERROR", message: rawData['message'] ?? "No products found", isError: true);
        producthasMoreData = false;
      }
    } else {
      if (retryCount < maxRetries) {
        print("Retrying getAllProducts: attempt ${retryCount + 1}");
        await Future.delayed(Duration(seconds: 2));
        return getAllProducts(pageNumber: pageNumber, retryCount: retryCount + 1);
      }
      print("Failed to fetch products: ${res.message}");
      UIHelper.showMySnak(title: "ERROR", message: res.message ?? "Failed to fetch products", isError: true);
      producthasMoreData = false;
    }
  } catch (e) {
    if (retryCount < maxRetries) {
      print("Retrying getAllProducts: attempt ${retryCount + 1}, error: $e");
      await Future.delayed(Duration(seconds: 2));
      return getAllProducts(pageNumber: pageNumber, retryCount: retryCount + 1);
    }
    print("Error in getAllProducts: $e");
    UIHelper.showMySnak(title: "ERROR", message: "Failed to load products: $e", isError: true);
    producthasMoreData = false;
  } finally {
    productisLoadingMore = false;
    notifyListeners();
  }
}

Future getAllProductsWithFilters({
  required int pageNumber,
  required String type,
  int retryCount = 0,
}) async {
  if (!producthasMoreData || productisLoadingMore) return;

  const maxRetries = 3;
  productisLoadingMore = true;
  if (pageNumber == 1) {
    productList.clear();
    productcurrentPage = 1;
    producthasMoreData = true;
  }
  notifyListeners();

  // Map type to productable_type (match cURL format)
  String productableType;
  if (type == 'm') {
    productableType = 'merchant';
  } else if (type == 'b') {
    productableType = 'bank';
  } else {
    print("Invalid type: $type");
    UIHelper.showMySnak(
      title: "ERROR",
      message: "Invalid filter type selected",
      isError: true,
    );
    productisLoadingMore = false;
    notifyListeners();
    return;
  }

  _logRequest('GET', 'getAllProductsWithFilters', params: {
    'pageNumber': pageNumber.toString(),
    'type': type,
    'productable_type': productableType,
  });

  AuthHttpApiRepository repository = AuthHttpApiRepository();
  try {
    ApiResponse res = await repository.getAllProductsWithFilters(
      PageNumber: pageNumber,
      type: type,
    );
    print(
        "Filtered API Response Status: ${res.status}, Message: ${res.message}, Data type: ${res.data.runtimeType}");

    if (res.status == Status.completed && res.data != null) {
      Responses ress = res.data as Responses;
      _logResponse('getAllProductsWithFilters', ress.data,
          statusCode: ress.status);

      if (ress.status == 1) {
        Map<String, dynamic> rawData = {
          "status": ress.status,
          "message": ress.message,
          "products": ress.data,
          "pagination": ress.pagination ?? {
            "page_no": pageNumber,
            "page_size": 10,
            "total": ress.data?.length ?? 0,
            "totalPages": ress.data?.isNotEmpty == true ? pageNumber + 1 : pageNumber,
          },
        };
        print("Parsing filtered products from rawData: ${jsonEncode(rawData)}");
        ProductModel model = ProductModel.fromJson(rawData);

        print(
            "Parsed Filtered ProductModel: status=${model.status}, products length=${model.products?.length ?? 0}");
        if (model.products != null && model.products!.isNotEmpty) {
          // Validate productable_type
          final expectedType = productableType == 'merchant' ? 'App\\Models\\Merchant' : 'App\\Models\\Bank';
          final filteredProducts = model.products!.where((p) => p.productableType == expectedType).toList();
          if (filteredProducts.isEmpty && model.products!.isNotEmpty) {
            print("Warning: API returned products with wrong productable_type. Expected: $expectedType");
          }
          productList.addAll(filteredProducts);
          productcurrentPage = pageNumber + 1;
          if (model.pagination.total != null &&
              model.pagination.totalPages != null) {
            producthasMoreData =
                model.pagination.pageNo < model.pagination.totalPages;
          } else {
            producthasMoreData = filteredProducts.length >= 10;
          }
          print(
              "Total filtered products loaded: ${productList.length}, Has more: $producthasMoreData, Products: ${productList.map((p) => "${p.name} (${p.productableType})").toList()}");
        } else {
          producthasMoreData = false;
          print("No filtered products available in response.");
          UIHelper.showMySnak(
            title: "INFO",
            message: type == 'm'
                ? "No merchants found."
                : "No banks found.",
            isError: false,
          );
        }
      } else {
        print("API status not successful: ${ress.message}");
        UIHelper.showMySnak(
          title: "ERROR",
          message: ress.message ?? "No filtered products found",
          isError: true,
        );
        producthasMoreData = false;
      }
    } else {
      if (retryCount < maxRetries) {
        print("Retrying getAllProductsWithFilters: attempt ${retryCount + 1}");
        await Future.delayed(Duration(seconds: 2));
        return getAllProductsWithFilters(
          pageNumber: pageNumber,
          type: type,
          retryCount: retryCount + 1,
        );
      }
      print("Failed to fetch filtered products: ${res.message}");
      UIHelper.showMySnak(
        title: "ERROR",
        message: res.message ?? "Failed to fetch filtered products",
        isError: true,
      );
      producthasMoreData = false;
    }
  } catch (e) {
    if (retryCount < maxRetries) {
      print(
          "Retrying getAllProductsWithFilters: attempt ${retryCount + 1}, error: $e");
      await Future.delayed(Duration(seconds: 2));
      return getAllProductsWithFilters(
        pageNumber: pageNumber,
        type: type,
        retryCount: retryCount + 1,
      );
    }
    print("Error in getAllProductsWithFilters: $e");
    UIHelper.showMySnak(
      title: "ERROR",
      message: "Failed to load filtered products: $e",
      isError: true,
    );
    producthasMoreData = false;
  } finally {
    productisLoadingMore = false;
    notifyListeners();
  }
}

  final List<CoinModel> _coins = [];
  List<CoinModel> _filteredCoins = [];
  int _offset = 0;
  bool _isFetching = false;
  bool _hasMore = true;

  List<CoinModel> get coins => _filteredCoins;
  bool get isFetching => _isFetching;

  Future<void> fetchCoins({int limit = 2, bool isRefresh = false}) async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    notifyListeners();

    if (isRefresh) {
      _offset = 0;
      _coins.clear();
      _filteredCoins.clear();
      _hasMore = true;
    }

    final url = Uri.parse('https://api.livecoinwatch.com/coins/list');
    const apiKey = '6170a07c-9d50-4fc1-89bc-3a9e7030751c';
    final body = jsonEncode({"currency": "USD", "sort": "rank", "order": "ascending", "offset": _offset, "limit": limit, "meta": true});

    _logRequest('POST', url.toString(), payload: body);

    final response = await http.post(url, headers: {'Content-Type': 'application/json', 'x-api-key': apiKey}, body: body);

    _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

    if (response.statusCode == 200) {
      List<CoinModel> newCoins = coinModelFromJson(response.body);
      if (newCoins.isNotEmpty) {
        _coins.addAll(newCoins);
        _filteredCoins = List.from(_coins);
        _offset += limit;
      } else {
        _hasMore = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: "Failed to load coins: ${response.statusCode}", isError: true);
    }
    _isFetching = false;
    notifyListeners();
  }

  Future<InvestmentRanking?> checkCoinSecurity({required String securityToken}) async {
    if (bankisLoadingMore) return null;
    bankisLoadingMore = true;
    notifyListeners();

    _logRequest('GET', 'checkCoinSecurity', params: {'securityToken': securityToken});

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.checkCoinSecurity(securityToken: securityToken);
    Responses ress = res.data;

    InvestmentRanking? investmentRanking;
    _logResponse('checkCoinSecurity', ress.data, statusCode: ress.status);

    if (res.status == Status.completed && ress.status == 1) {
      investmentRanking = InvestmentRanking.fromJson(ress.data["investmentRanking"]);
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message.toString(), isError: true);
    }
    bankisLoadingMore = false;
    notifyListeners();
    return investmentRanking;
  }

  Future<Map<String, dynamic>?> fetchCoinAnalysis({required CoinModel coin}) async {
    final url = Uri.parse('https://api.buzdy.com/coinanalysis?isPremium=true');
    Map<String, dynamic> body = {
      "crypto": {
        "name": coin.name,
        "price": coin.rate ?? 0,
        "performance": {"day": coin.delta?.day ?? 0},
        "volume": coin.volume ?? 0,
        "technicals": {"rsi": 55},
        "btc_correlation": 0.0
      },
      "preferences": {"risk_tolerance": "moderate"},
      "timeframe": "short-term"
    };

    _logRequest('POST', url.toString(), payload: body);

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        },
        body: jsonEncode(body));

    _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      UIHelper.showMySnak(
          title: "ERROR",
          message: "Failed to fetch analysis: ${response.statusCode}",
          isError: true);
      return null;
    }
  }

  /// Fetch detailed coin information from LiveCoinWatch
  Future<CoinModel?> fetchCoinDetail(String symbol) async {
    final url = Uri.parse('https://api.livecoinwatch.com/coins/single');
    const apiKey = '6170a07c-9d50-4fc1-89bc-3a9e7030751c';
    final body = jsonEncode({
      "currency": "USD",
      "code": symbol.toUpperCase(),
      "meta": true
    });

    _logRequest('POST', url.toString(), payload: body);

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey
        },
        body: body);

    _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

    if (response.statusCode == 200) {
      return CoinModel.fromJson(jsonDecode(response.body));
    } else {
      UIHelper.showMySnak(
          title: "ERROR",
          message: "Failed to load coin details: ${response.statusCode}",
          isError: true);
      return null;
    }
  }

  void searchCoins(String query) {
    if (query.isEmpty) {
      _filteredCoins = List.from(_coins);
    } else {
      _filteredCoins = _coins
          .where((coin) =>
              coin.name.toLowerCase().contains(query.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  List<Item> youtubeShorts = [];
  List<Item> youtubeVideos = [];
  String? nextPageTokenShorts;
  String? nextPageTokenVideos;
  bool isFetchingShorts = false;
  bool isFetchingVideos = false;
  bool hasMoreShorts = true;
  bool hasMoreVideos = true;

  Future<void> fetchYoutubeShorts({bool isRefresh = false}) async {
    if (isFetchingShorts || !hasMoreShorts) return;
    isFetchingShorts = true;
    notifyListeners();

    if (isRefresh) {
      nextPageTokenShorts = null;
      youtubeShorts.clear();
      hasMoreShorts = true;
    }

    var url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&channelId=UCZNZj3mkdCGJfCoKyl4bSYQ&maxResults=5&pageToken=${nextPageTokenShorts ?? ''}&key=AIzaSyATK5cfxRwEFXlp73Su6HrExL5_6Z0puYw');

    _logRequest('GET', url.toString());

    var response = await http.get(url);

    _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      YoutubeModel youtubeModel = YoutubeModel.fromJson(jsonResponse);
      if (youtubeModel.items != null && youtubeModel.items!.isNotEmpty) {
        youtubeShorts.addAll(youtubeModel.items!);
        nextPageTokenShorts = youtubeModel.nextPageToken;
      } else {
        hasMoreShorts = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: "Failed to load YouTube shorts: ${response.statusCode}", isError: true);
    }
    isFetchingShorts = false;
    notifyListeners();
  }

  Future<void> fetchYoutubeVideos({bool isRefresh = false}) async {
    if (isFetchingVideos || !hasMoreVideos) return;
    isFetchingVideos = true;
    notifyListeners();

    if (isRefresh) {
      nextPageTokenVideos = null;
      youtubeVideos.clear();
      hasMoreVideos = true;
    }

    var url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&channelId=UCqK_GSMbpiV8spgD3ZGloSw&maxResults=10&pageToken=${nextPageTokenVideos ?? ''}&key=AIzaSyATK5cfxRwEFXlp73Su6HrExL5_6Z0puYw');

    _logRequest('GET', url.toString());

    var response = await http.get(url);

    _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      YoutubeModel youtubeModel = YoutubeModel.fromJson(jsonResponse);
      if (youtubeModel.items != null && youtubeModel.items!.isNotEmpty) {
        youtubeVideos.addAll(youtubeModel.items!);
        nextPageTokenVideos = youtubeModel.nextPageToken;
      } else {
        hasMoreVideos = false;
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: "Failed to load YouTube videos: ${response.statusCode}", isError: true);
    }
    isFetchingVideos = false;
    notifyListeners();
  }

  Future<List<BubbleCoinModel>> fetchBubbleCoins() async {
    try {
      final url = Uri.parse('https://cryptobubbles.net/backend/data/bubbles1000.usd.json');
      _logRequest('GET', url.toString());

      final response = await http.get(url, headers: {'Accept': 'application/json'});

      _logResponse(url.toString(), jsonDecode(response.body), statusCode: response.statusCode);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        bubbleCoins = jsonData.map((data) => BubbleCoinModel.fromJson(data)).toList();
        notifyListeners();
        return bubbleCoins;
      } else {
        throw Exception('Failed to load bubble coins: ${response.statusCode}');
      }
    } catch (e) {
      UIHelper.showMySnak(title: "Error", message: "Failed to load data: $e", isError: true);
      return [];
    }
  }

  void easyLoadingStart({dynamic status}) {
    EasyLoading.show(indicator: Lottie.asset("images/buzdysplash.json", width: 150, height: 150));
    notifyListeners();
  }

  void easyLoadingStop() {
    EasyLoading.dismiss();
    notifyListeners();
  }

  Future<void> savetoken({required String token}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', token);
  }

  Future<void> saveUserId({required String userId}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('userId', userId);
  }

  void refresh() {
    notifyListeners();
  }
}