import 'dart:convert';
import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/presentation/dashboard/dashboard_screen.dart';
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

  UserModelData? userModel;
  List<BubbleCoinModel> bubbleCoins = [];

  UserViewModel() {
    getAllBanks(pageNumber: bankcurrentPage);
    getAllMarchants(pageNumber: merchantcurrentPage);
    fetchCoins(limit: 25);
    fetchBubbleCoins();
  }

  Future getAllBanks({required int pageNumber}) async {
    if (!bankhasMoreData || bankisLoadingMore) return;

    bankisLoadingMore = true;
    notifyListeners();
    print("Fetching all banks for page: $pageNumber, current list size: ${bankList.length}");

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllBanks(PageNumber: pageNumber);

    if (res.status == Status.completed) {
      Responses ress = res.data;
      print("Raw API response for getAllBanks: ${jsonEncode(ress.data)}");
      if (ress.status == 1) {
        try {
          BankModel model = BankModel.fromJson({
            "status": ress.status,
            "message": ress.message,
            "banks": ress.data,
            "pagination": ress.pagination ?? {"page_no": pageNumber, "page_size": 10, "total": 0, "totalPages": 1}
          });
          print("Received ${model.banks.length} banks, Total pages: ${model.pagination.totalPages}");

          if (model.banks.isNotEmpty && pageNumber <= model.pagination.totalPages!) {
            bankList.addAll(model.banks);
            bankcurrentPage++;
            bankhasMoreData = pageNumber < model.pagination.totalPages!;
            print("Updated bank list size: ${bankList.length}, hasMoreData: $bankhasMoreData");
          } else {
            bankhasMoreData = false;
            print("No more banks to load");
          }
        } catch (e) {
          print("Error parsing BankModel: $e");
          UIHelper.showMySnak(title: "ERROR", message: "Failed to parse bank data: $e", isError: true);
        }
      } else {
        UIHelper.showMySnak(title: "ERROR", message: ress.message.toString(), isError: true);
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message.toString(), isError: true);
    }

    bankisLoadingMore = false;
    notifyListeners();
  }

  Future getBanksByCountry({required String country}) async {
  bankisLoadingMore = true;
  bankList.clear();
  bankcurrentPage = 1;
  bankhasMoreData = false;
  notifyListeners();
  print("Fetching banks for country: $country");

  AuthHttpApiRepository repository = AuthHttpApiRepository();
  ApiResponse res = await repository.getBanksByCountry(country: country);

  if (res.status == Status.completed) {
    Responses ress = res.data;
    print("Raw API response for getBanksByCountry: ${jsonEncode(ress.data)}");
    if (ress.status == 1) {
      try {
        // ress.data is now the "banks" list directly
        BankModel model = BankModel.fromJson({
          "status": ress.status,
          "message": ress.message,
          "banks": ress.data, // Use ress.data directly
          "pagination": {"page_no": 1, "page_size": ress.data.length, "total": ress.data.length, "totalPages": 1}
        });
        bankList.addAll(model.banks);
        print("Received ${model.banks.length} banks for $country");
      } catch (e) {
        print("Error parsing BankModel for country filter: $e");
        UIHelper.showMySnak(title: "ERROR", message: "Failed to parse bank data: $e", isError: true);
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: ress.message.toString(), isError: true);
    }
  } else {
    UIHelper.showMySnak(title: "ERROR", message: res.message.toString(), isError: true);
  }

  bankisLoadingMore = false;
  notifyListeners();
}

  Future login({dynamic payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    ApiResponse res = await repository.loginApi(payload);
    Responses ress = res.data;

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
    try {
      ApiResponse res = await repository.registerApi(payload);
      if (res.data == null) {
        easyLoadingStop();
        UIHelper.showMySnak(title: "ERROR", message: "Unexpected error. Please try again.", isError: true);
        return;
      }
      Responses ress = res.data;
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

  Future getAllMarchants({required int pageNumber}) async {
  if (!merchanthasMoreData || merchantisLoadingMore) return;

  merchantisLoadingMore = true;
  notifyListeners();
  print("Fetching merchants for page: $pageNumber, current list size: ${merchantList.length}");

  AuthHttpApiRepository repository = AuthHttpApiRepository();
  ApiResponse res = await repository.getAllMerchants(PageNumber: pageNumber);

  if (res.status == Status.completed) {
    Responses ress = res.data;
    print("Raw API response for getAllMarchants: ${jsonEncode(ress.data)}");
    if (ress.status == 1) {
      try {
        MerchantModel model = MerchantModel.fromJson({
          "status": ress.status,
          "message": ress.message,
          "merchants": ress.data,
          "pagination": ress.pagination ?? {"page_no": pageNumber, "page_size": 10, "total": 0, "totalPages": 1}
        });
        print("Received ${model.merchants.length} merchants, Total pages: ${model.pagination.totalPages}");

        if (model.merchants.isNotEmpty && pageNumber <= model.pagination.totalPages) {
          merchantList.addAll(model.merchants);
          merchantcurrentPage++;
          merchanthasMoreData = pageNumber < model.pagination.totalPages;
          print("Updated merchant list size: ${merchantList.length}, hasMoreData: $merchanthasMoreData");
        } else {
          merchanthasMoreData = false;
          print("No more merchants to load");
        }
      } catch (e) {
        print("Error parsing MerchantModel: $e");
        UIHelper.showMySnak(title: "ERROR", message: "Failed to parse merchant data: $e", isError: true);
      }
    } else {
      UIHelper.showMySnak(title: "ERROR", message: ress.message.toString(), isError: true);
    }
  } else {
    UIHelper.showMySnak(title: "ERROR", message: res.message.toString(), isError: true);
  }

  merchantisLoadingMore = false;
  notifyListeners();
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

    final response = await http.post(url, headers: {'Content-Type': 'application/json', 'x-api-key': apiKey}, body: body);

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
      throw Exception('Failed to load coins');
    }
    _isFetching = false;
    notifyListeners();
  }

  Future<InvestmentRanking?> checkCoinSecurity({required String securityToken}) async {
    if (bankisLoadingMore) return null;
    bankisLoadingMore = true;
    notifyListeners();

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.checkCoinSecurity(securityToken: securityToken);
    Responses ress = res.data;
    InvestmentRanking? investmentRanking;

    if (res.status == Status.completed && ress.status == 1) {
      investmentRanking = InvestmentRanking.fromJson(ress.data["investmentRanking"]);
    } else {
      UIHelper.showMySnak(title: "ERROR", message: res.message.toString(), isError: true);
    }
    bankisLoadingMore = false;
    notifyListeners();
    return investmentRanking;
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
        'https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCZNZj3mkdCGJfCoKyl4bSYQ&maxResults=5&pageToken=${nextPageTokenShorts ?? ''}&key=AIzaSyATK5cfxRwEFXlp73Su6HrExL5_6Z0puYw');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      YoutubeModel youtubeModel = YoutubeModel.fromJson(jsonResponse);
      if (youtubeModel.items != null && youtubeModel.items!.isNotEmpty) {
        youtubeShorts.addAll(youtubeModel.items!);
        nextPageTokenShorts = youtubeModel.nextPageToken;
      } else {
        hasMoreShorts = false;
      }
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
        'https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCZNZj3mkdCGJfCoKyl4bSYQ&maxResults=10&pageToken=${nextPageTokenVideos ?? ''}&key=AIzaSyATK5cfxRwEFXlp73Su6HrExL5_6Z0puYw');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      YoutubeModel youtubeModel = YoutubeModel.fromJson(jsonResponse);
      if (youtubeModel.items != null && youtubeModel.items!.isNotEmpty) {
        youtubeVideos.addAll(youtubeModel.items!);
        nextPageTokenVideos = youtubeModel.nextPageToken;
      } else {
        hasMoreVideos = false;
      }
    }
    isFetchingVideos = false;
    notifyListeners();
  }

  Future<List<BubbleCoinModel>> fetchBubbleCoins() async {
    try {
      final response = await http.get(
        Uri.parse('https://cryptobubbles.net/backend/data/bubbles1000.usd.json'),
        headers: {'Accept': 'application/json'},
      );

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

  easyLoadingStart({dynamic status}) {
    EasyLoading.show(indicator: Lottie.asset("images/buzdysplash.json", width: 150, height: 150));
    notifyListeners();
  }

  easyLoadingStop() {
    EasyLoading.dismiss();
    notifyListeners();
  }

  savetoken({required String token}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', token);
  }

  saveUserId({required String userId}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('userId', userId);
  }

  refresh() {
    notifyListeners();
  }
}