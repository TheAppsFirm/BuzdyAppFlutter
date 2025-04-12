import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/network/base_api_services.dart';
import 'package:buzdy/network/network_api_services.dart';
import 'package:buzdy/response/api_response.dart';
import 'package:get/get.dart';

import 'auth_repository.dart';

class AuthHttpApiRepository implements AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  void _logError(String method, String endpoint, dynamic error, {int? statusCode}) {
    print('=== ERROR ===');
    print('Method: $method');
    print('Endpoint: $endpoint');
    print('Status Code: $statusCode');
    print('Error: $error');
    print('Timestamp: ${DateTime.now().toIso8601String()}');
    print('============');
  }

  @override
  Future<ApiResponse<Responses>> loginApi(dynamic data) async {
    try {
      final response = await _apiServices
          .getPostApiResponse(_apiServices.getBaseURL() + _apiServices.getLoginEndPoint(), data)
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('POST', _apiServices.getBaseURL() + _apiServices.getLoginEndPoint(), error);
      return ApiResponse.error("Failed to login: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> registerApi(dynamic data) async {
    try {
      final response = await _apiServices
          .getPostApiResponse(_apiServices.getBaseURL() + _apiServices.getRegisterEndPoint(), data)
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('POST', _apiServices.getBaseURL() + _apiServices.getRegisterEndPoint(), error);
      Get.back();
      return ApiResponse.error("Failed to register: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> updateProfile(dynamic data, token) async {
    try {
      final response = await _apiServices
          .getPutApiResponse(_apiServices.getBaseURL() + _apiServices.updateProfile(), data, token)
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('PUT', _apiServices.getBaseURL() + _apiServices.updateProfile(), error);
      return ApiResponse.error("Failed to update profile: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> getAllBanks({int PageNumber = 1}) async {
    try {
      final response = await _apiServices
          .getGetApiResponse(_apiServices.getAllBankEndPoint(pageNumber: PageNumber))
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('GET', _apiServices.getAllBankEndPoint(pageNumber: PageNumber), error);
      return ApiResponse.error("Failed to fetch banks: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> getBanksByCountry({
    required String country,
    String? city,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'country': country,
        if (city != null) 'city': city,
        'page_no': pageNumber.toString(),
        'page_size': pageSize.toString(),
      };
      final endpoint = Uri.https('api.buzdy.com', '/banks/getbyfilters', queryParams).toString();
      final response = await _apiServices
          .getGetApiResponse(endpoint)
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('GET', '/banks/getbyfilters', error);
      return ApiResponse.error("Failed to fetch banks by country: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> checkCoinSecurity({securityToken}) async {
    try {
      final response = await _apiServices
          .getGetApiResponse(_apiServices.rugChecktEndPoint(securityToken: securityToken))
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('GET', _apiServices.rugChecktEndPoint(securityToken: securityToken), error);
      return ApiResponse.error("Failed to check coin security: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> getAllMerchants({int PageNumber = 1}) async {
    try {
      final response = await _apiServices
          .getGetApiResponse(_apiServices.getAllMerchantEndPoint(pageNumber: PageNumber))
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('GET', _apiServices.getAllMerchantEndPoint(pageNumber: PageNumber), error);
      return ApiResponse.error("Failed to fetch merchants: $error");
    }
  }

  @override
  Future<ApiResponse<Responses>> getMerchantsByCountry({
    required String country,
    String? city,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'country': country,
        if (city != null) 'city': city,
        'page_no': pageNumber.toString(),
        'page_size': pageSize.toString(),
      };
      final endpoint = Uri.https('api.buzdy.com', '/merchants/getbyfilters', queryParams).toString();
      final response = await _apiServices
          .getGetApiResponse(endpoint)
          .then((value) => ApiResponse.completed(Responses.fromJson(value)));
      return response;
    } catch (error) {
      _logError('GET', '/merchants/getbyfilters', error);
      return ApiResponse.error("Failed to fetch merchants by country: $error");
    }
  }

  // Only showing the updated `getAllProducts` method for brevity. Replace this in your existing `AuthHttpApiRepository` class.

Future<ApiResponse<Responses>> getAllProducts({int PageNumber = 1}) async {
  try {
    final queryParams = {
      'page_no': PageNumber.toString(),
      'page_size': '10',
    };
    final endpoint = Uri.https('api.buzdy.com', '/products', queryParams).toString();
    print("Fetching products from: $endpoint");
    final rawResponse = await _apiServices.getGetApiResponse(endpoint);
    print("Raw Product Response: $rawResponse");

    if (rawResponse == null) {
      throw Exception("API returned null response");
    }
    final responses = Responses.fromJson(rawResponse);
    print("Parsed Responses: status=${responses.status}, products length=${responses.data?.length ?? 0}");
    return ApiResponse.completed(responses);
  } catch (error) {
    _logError('GET', '/products?page_no=$PageNumber&page_size=10', error);
    return ApiResponse.error("Failed to fetch products: $error");
  }
}

  Future<ApiResponse<Responses>> getAllProductsWithFilters({
  required int PageNumber,
  required String type,
}) async {
  try {
    final productableType = type == 'm' ? 'merchant' : 'bank';
    final queryParams = {
      'productable_id': '0',
      'productable_type': productableType,
      'category_id': '0',
      'page_no': PageNumber.toString(),
      'page_size': '10',
      'ratingstart': '0', // Match cURL
    };
    final endpoint =
        Uri.https('api.buzdy.com', '/products/getbyfilters', queryParams)
            .toString();
    print("Fetching filtered products from: $endpoint");
    final rawResponse = await _apiServices.getGetApiResponse(endpoint);
    print("Raw Filtered Product Response: $rawResponse");

    if (rawResponse == null) {
      throw Exception("API returned null response");
    }
    final responses = Responses.fromJson(rawResponse);
    print(
        "Parsed Filtered Responses: status=${responses.status}, products length=${responses.data?.length ?? 0}");
    return ApiResponse.completed(responses);
  } catch (error) {
    _logError('GET', '/products/getbyfilters', error);
    return ApiResponse.error("Failed to fetch filtered products: $error");
  }
}
}