// ignore_for_file: invalid_return_type_for_catch_error

import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/network/base_api_services.dart';
import 'package:buzdy/network/network_api_services.dart';
import 'package:buzdy/response/api_response.dart';
import 'package:get/get.dart';

import 'auth_repository.dart';

class AuthHttpApiRepository implements AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<ApiResponse<Responses>> loginApi(dynamic data) async {
    try {
      dynamic response = await _apiServices
          .getPostApiResponse(
              _apiServices.getBaseURL() + _apiServices.getLoginEndPoint(), data)
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      });
      return response;
    } catch (error) {
      return ApiResponse.error(error.toString());
    }
  }

  @override
  Future<ApiResponse<Responses>> registerApi(dynamic data) async {
    try {
      dynamic response = await _apiServices
          .getPostApiResponse(
              _apiServices.getBaseURL() + _apiServices.getRegisterEndPoint(),
              data)
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      });
      return response;
    } catch (error) {
      Get.back();
      return ApiResponse.error(error.toString());
    }
  }

  // profile

  @override
  Future<ApiResponse<Responses>> updateProfile(dynamic data, token) async {
    try {
      dynamic response = await _apiServices
          .getPutApiResponse(
              _apiServices.getBaseURL() + _apiServices.updateProfile(),
              data,
              token)
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      });
      return response;
    } catch (error) {
      return ApiResponse.error(error.toString());
    }
  }

  @override
  Future<ApiResponse<Responses>> getAllBanks({int PageNumber = 1}) async {
    ApiResponse<Responses> response = ApiResponse.notStarted();
    try {
      response = ApiResponse.loading();
      dynamic result = await _apiServices
          .getGetApiResponse(
              _apiServices.getAllBankEndPoint(pageNumber: PageNumber))
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      }).catchError((error, stackTrace) {
        return ApiResponse.error(error.toString());
      });
      response = result;
    } catch (error) {
      response = ApiResponse.error(error.toString());
    }
    return response;
  }

  @override
  Future<ApiResponse<Responses>> checkCoinSecurity({securityToken}) async {
    ApiResponse<Responses> response = ApiResponse.notStarted();
    try {
      response = ApiResponse.loading();
      dynamic result = await _apiServices
          .getGetApiResponse(
              _apiServices.rugChecktEndPoint(securityToken: securityToken))
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      }).catchError((error, stackTrace) {
        return ApiResponse.error(error.toString());
      });
      response = result;
    } catch (error) {
      response = ApiResponse.error(error.toString());
    }
    return response;
  }

  @override
  Future<ApiResponse<Responses>> getAllMerchants({int PageNumber = 1}) async {
    ApiResponse<Responses> response = ApiResponse.notStarted();
    try {
      response = ApiResponse.loading();
      dynamic result = await _apiServices
          .getGetApiResponse(
              _apiServices.getAllMerchantEndPoint(pageNumber: PageNumber))
          .then((value) {
        return ApiResponse.completed(Responses.fromJson(value));
      }).catchError((error, stackTrace) {
        return ApiResponse.error(error.toString());
      });
      response = result;
    } catch (error) {
      response = ApiResponse.error(error.toString());
    }
    return response;
  }
}
