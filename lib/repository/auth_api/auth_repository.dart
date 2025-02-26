import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/response/api_response.dart';

abstract class AuthRepository {
  Future<ApiResponse<Responses>> loginApi(dynamic data);
  Future<ApiResponse<Responses>> registerApi(dynamic data);
  Future<ApiResponse<Responses>> updateProfile(dynamic data, token);
  Future<ApiResponse<Responses>> getAllBanks();
  Future<ApiResponse<Responses>> getAllMerchants();
  Future<ApiResponse<Responses>> checkCoinSecurity({securityToken});
}
