import 'dart:convert';

import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/repository/auth_api/auth_http_api_repository.dart';
import 'package:buzdy/response/api_response.dart';
import 'package:buzdy/response/status.dart';
import 'package:buzdy/screens/auth/model/userModel.dart';
import 'package:buzdy/screens/dashboard.dart';
import 'package:buzdy/screens/dashboard/deals/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/screens/dashboard/deals/model.dart/coinModel.dart';
import 'package:buzdy/screens/dashboard/deals/model.dart/rugcheckModel.dart';
import 'package:buzdy/screens/dashboard/feed/model/youtubeModel.dart';
import 'package:buzdy/screens/dashboard/banks/model/bankModel.dart';
import 'package:buzdy/screens/dashboard/banks/model/merchnatModel.dart';
import 'package:buzdy/views/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> listCoins = [];

  // Bank Data
  List<Bank> bankList = [];
  int bankcurrentPage = 1; // Track the current page
  bool bankisLoadingMore = false; // Track if more data is being fetched
  bool bankhasMoreData = true; // If no more pages, stop loading

  //Merchant Data
  List<MerchantModelData> merchantList = [];

  int merchantcurrentPage = 1; // Track the current page
  bool merchantisLoadingMore = false; // Track if more data is being fetched
  bool merchanthasMoreData = true; // If no more pages, stop loading

  UserModelData? userModel;

  List<BubbleCoinModel> bubbleCoins = [];
  UserViewModel() {
    getAllBanks(pageNumber: bankcurrentPage);
    getAllMarchants(pageNumber: merchantcurrentPage);
    fetchCoins(limit: 10);
    fetchBubbleCoins();
  }
  // auth
  Future login({payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    ApiResponse res = await repository.loginApi(payload);
    print(res.data);
    Responses ress = res.data;

    if (ress.status == 1) {
      print("RESPOSNE----------- ${ress.data}");
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "Buzdy", message: "Login successfully", isError: false);

      userModel = UserModelData.fromJson(ress.data);
      await savetoken(token: ress.data['token'].toString());
      await saveUserId(userId: ress.data['id'].toString());

      print("Save UserModel ${userModel!.toJson().toString()}");

      // await savePhone(phone: payload['phoneNumber']);
      Get.offAll(DashBorad(index: 0));

      notifyListeners();
      //  await getApiToken();
    } else {
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "ERROR", message: ress.message.toString(), isError: true);
    }
  }

//register
  Future register({payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();

    try {
      ApiResponse res = await repository.registerApi(payload);

      // Ensure that res.data is properly initialized
      if (res.data == null) {
        easyLoadingStop();
        UIHelper.showMySnak(
            title: "ERROR",
            message: "Unexpected error. Please try again.",
            isError: true);
        return;
      }

      Responses ress = res.data;

      if (ress.status == 1) {
        print("RESPONSE----------- ${ress.data}");
        easyLoadingStop();
        UIHelper.showMySnak(
            title: "Buzdy",
            message: ress.message ?? "Signup successful",
            isError: false);

        userModel = UserModelData.fromJson(ress.data);
        await savetoken(token: ress.data['token'].toString());
        await saveUserId(userId: ress.data['id'].toString());
        print("Save UserModel ${userModel!.toJson().toString()}");
        Get.offAll(DashBorad(index: 0));
        notifyListeners();
      } else {
        easyLoadingStop();
        UIHelper.showMySnak(
            title: "ERROR",
            message: ress.message ?? "Something went wrong",
            isError: true);
      }
    } catch (e) {
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "ERROR",
          message: "An unexpected error occurred: $e",
          isError: true);
      print("Register API Error: $e");
    }
  }

  fetchUserById() {}

  // banks
  Future getAllBanks({required int pageNumber}) async {
    print("bank---------");
    if (bankisLoadingMore) return; // Prevent multiple API calls

    bankisLoadingMore = true;
    notifyListeners();

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllBanks(PageNumber: pageNumber);

    if (res.status == Status.completed) {
      Responses ress = res.data;
      if (ress.status == 1) {
        BankModel model = BankModel.fromJson({
          "status": ress.status,
          "message": ress.message,
          "banks": ress.data,
          "pagination": ress.pagination
        });

        if (model.banks.isNotEmpty) {
          bankList.addAll(model.banks); // Append new banks to the list
          bankcurrentPage++; // Move to next page
          print("Fetching more banks... Page: $pageNumber");
          print("Total banks loaded: ${bankList.length}");
        } else {
          bankhasMoreData = false; // No more data to load
        }
      }
    } else {
      UIHelper.showMySnak(
          title: "ERROR", message: res.message.toString(), isError: true);
    }

    bankisLoadingMore = false;
    notifyListeners();
  }

  Future getAllMarchants({required int pageNumber}) async {
    print("merchnat---------");

    if (merchantisLoadingMore) return; // Prevent multiple API calls

    merchantisLoadingMore = true;
    notifyListeners();

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllMerchants(PageNumber: pageNumber);

    if (res.status == Status.completed) {
      Responses ress = res.data;
      if (ress.status == 1) {
        MerchantModel model = MerchantModel.fromJson({
          "status": ress.status,
          "message": ress.message,
          "merchants": ress.data,
          "pagination": ress.pagination
        });

        if (model.merchants.isNotEmpty) {
          merchantList.addAll(model.merchants); // Append new banks to the list
          merchantcurrentPage++; // Move to next page
          print("Fetching more merchnats... Page: $pageNumber");
          print("Total merchants loaded: ${merchantList.length}");
        } else {
          merchanthasMoreData = false; // No more data to load
        }
      }
    } else {
      UIHelper.showMySnak(
          title: "ERROR", message: res.message.toString(), isError: true);
    }

    merchantisLoadingMore = false;
    notifyListeners();
  }

// deals
  final List<CoinModel> _coins = [];
  List<CoinModel> _filteredCoins = [];
  int _offset = 0;
  bool _isFetching = false;
  bool _hasMore = true;

  List<CoinModel> get coins => _filteredCoins;
  bool get isFetching => _isFetching;

  Future<void> fetchCoins({int limit = 10, bool isRefresh = false}) async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    notifyListeners();

    if (isRefresh) {
      _offset = 0;
      _coins.clear();
      _filteredCoins.clear();
      _hasMore = true;
    }

    final url = Uri.parse(
        'https://frontend-api.pump.fun/coins?offset=$_offset&limit=$limit&sort=last_trade_timestamp&order=DESC&includeNsfw=false');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<CoinModel> newCoins =
          jsonData.map((coin) => CoinModel.fromJson(coin)).toList();

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

  Future<InvestmentRanking?> checkCoinSecurity(
      {required String securityToken}) async {
    print("checkCoinSecurity---------");
    if (bankisLoadingMore) return null; // Prevent multiple API calls

    bankisLoadingMore = true;
    notifyListeners();

    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res =
        await repository.checkCoinSecurity(securityToken: securityToken);
    print(" RESPONSE---------- ${res.data.toString()}");

    Responses ress = res.data;

    InvestmentRanking? investmentRanking;

    if (res.status == Status.completed) {
      if (ress.status == 1) {
        // ✅ Extracting InvestmentRanking
        investmentRanking =
            InvestmentRanking.fromJson(ress.data["investmentRanking"]);

        print("RESPONSE----------- ${investmentRanking.toJson().toString()}");
        notifyListeners();
      }
    } else {
      UIHelper.showMySnak(
          title: "ERROR", message: res.message.toString(), isError: true);
    }

    bankisLoadingMore = false;
    notifyListeners();

    // ✅ Return Investment Ranking Data
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

  /// **Fetch YouTube Shorts (Horizontal List)**
  Future<void> fetchYoutubeShorts({bool isRefresh = false}) async {
    if (isFetchingShorts || !hasMoreShorts) return;

    isFetchingShorts = true;
    notifyListeners();

    if (isRefresh) {
      nextPageTokenShorts = null;
      youtubeShorts.clear();
      hasMoreShorts = true;
    }

    try {
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
      } else {
        print("Error fetching YouTube Shorts: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception while fetching YouTube Shorts: $e");
    }

    isFetchingShorts = false;
    notifyListeners();
  }

  /// **Fetch YouTube Videos (Vertical List)**
  Future<void> fetchYoutubeVideos({bool isRefresh = false}) async {
    if (isFetchingVideos || !hasMoreVideos) return;

    isFetchingVideos = true;
    notifyListeners();

    if (isRefresh) {
      nextPageTokenVideos = null;
      youtubeVideos.clear();
      hasMoreVideos = true;
    }

    try {
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
      } else {
        print("Error fetching YouTube Videos: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception while fetching YouTube Videos: $e");
    }

    isFetchingVideos = false;
    notifyListeners();
  }

  Future<List<BubbleCoinModel>> fetchBubbleCoins() async {
    try {
      print("fetchBubbleCoins---------");
      var request = http.Request(
        'GET',
        Uri.parse(
            'https://cryptobubbles.net/backend/data/bubbles1000.usd.json'),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        List<dynamic> jsonData = jsonDecode(responseData);
        print(jsonData.length.toString());

        // Parse top 50 coins only
        List<BubbleCoinModel> coins = jsonData
            .map((coin) => BubbleCoinModel.fromJson(coin))
            .toList()
            .sublist(0, 50);

        bubbleCoins = coins;
        notifyListeners();
        print("coins.length: ${coins.length}");

        return coins;
      } else {
        print("Error fetching data: ${response.reasonPhrase}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }

  easyLoadingStart({status}) {
    EasyLoading.show(
      indicator:
          Lottie.asset("images/buzdysplash.json", width: 150, height: 150),
    );
    notifyListeners();
  }

  easyLoadingStop() {
    EasyLoading.dismiss();
    notifyListeners();
  }

  savetoken({token}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', token);
    print("token saved successfully: $token");
  }

  saveUserId({userId}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', userId);
    print("userId saved successfully: $userId");
  }

  refresh() {
    notifyListeners();
  }
}
