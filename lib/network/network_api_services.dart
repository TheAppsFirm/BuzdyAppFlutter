// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buzdy/network/app_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_api_services.dart';

class NetworkApiService implements BaseApiServices {
  final String _baseUrl = "https://api.buzdy.com";
  final String _registrationEndPoint = "/auth/registeruser";
  final String _loginEndPoint = "/users/signin";
  final String _registerEndPoint = "/users/signin";

  final String _updateProfile = "/api/customer/updateProfile";

  @override
  String getBaseURL() {
    return _baseUrl;
  }

  @override
  String getAllBankEndPoint({pageNumber}) {
    return "https://api.buzdy.com/banks?page_no=$pageNumber&page_size=10";
  }

  @override
  String updateProfile() {
    return _updateProfile;
  }

  @override
  String getRegistrationEndPoint() {
    return _registrationEndPoint;
  }

  @override
  String getLoginEndPoint() {
    return _loginEndPoint;
  }

  @override
  String getRegisterEndPoint() {
    return _registerEndPoint;
  }

  @override
  Future getGetApiResponse(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    try {
      var header = {
        'accept': '/',
      };
      if (kDebugMode) {
        // print("headers: $header");
      }
      final response = await http
          .get(Uri.parse(url), headers: header)
          .timeout(const Duration(seconds: 20));
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  @override
  Future getPostApiResponse(String url, dynamic data,
      {String token = "", String cookies = ""}) async {
    if (kDebugMode) {
      print("running api url: $url");
      print("payload: $data");
    }
    // if (url == _baseUrl + _getRefreshCode) {
    //   print("called this url:  ${_baseUrl + _getRefreshCode}");
    // }

    dynamic responseJson;
    try {
      var headers = {
        'accept': '/',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': "Bearer $token",
        if (cookies.isNotEmpty) 'Cookie': '$cookies'
      };
      if (kDebugMode) {
        print("headers: $headers");
      }
      Response response =
          await post(Uri.parse(url), headers: headers, body: jsonEncode(data))
              .timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    } catch (e) {
      throw FetchDataException('An error occurred: $e');
    }

    return responseJson;
  }

  @override
  Future deleteApi(String url, String token) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    try {
      var header = {
        'accept': '*/*',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token'
      };
      final response = await http
          .delete(Uri.parse(url), headers: header)
          .timeout(const Duration(seconds: 20));
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    } catch (e) {
      throw FetchDataException('An error occurred: $e');
    }
    return responseJson;
  }

  @override
  Future getPutApiResponse(String url, dynamic data, String token) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? code = prefs.getString('refreshCode');
      var headers = {
        'accept': '/',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // 'cookie': '$code'
      };
      Response response =
          await put(Uri.parse(url), headers: headers, body: jsonEncode(data))
              .timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
      // if (url == _baseUrl + _loginEndPoint ||
      //     url == _baseUrl + _getRefreshCode) {
      //   fetchCookies(response);
      // }
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    } catch (e) {
      throw FetchDataException('An error occurred: $e');
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    if (kDebugMode) {
      print(response.statusCode);
      print("API Response : ${response.body.toString()}");
    }
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 401:
        dynamic responseJson = jsonDecode(response.body);
        // final session = SessionController.instance;
        // session.endSession();
        return responseJson;
      case 400:
        throw BadRequestException();
      case 500:
        throw FetchDataException();
      case 404:
        throw UnauthorisedException();
      default:
        throw FetchDataException(
            'Error occured while communicating with server with status code : ${response.body.toString()}');
    }
  }

  Future<void> fetchCookies(response) async {
    String? rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      List<String> cookies = rawCookies.split(';');
      String exp = cookies[1].split(',')[1].trim();
      String tokenCode = cookies[0];
      if (kDebugMode) {
        print('TokenCode: $tokenCode');
        print('ExpiryDate saved: $exp');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('RefreshCode', tokenCode);
      await prefs.setString('ExpiryDate', exp);
      print('RefreshToken saved to SharedPreferences');
    } else {
      if (kDebugMode) {
        print('No cookies found');
      }
    }
  }
}
