abstract class BaseApiServices {
  String getBaseURL();
  String getAllBankEndPoint({pageNumber});
  String getAllMerchantEndPoint({pageNumber});
  String rugChecktEndPoint({securityToken});

  String updateProfile();
  String getLoginEndPoint();
  String getRegisterEndPoint();

  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getPostApiResponse(String url, dynamic data,
      {String token = "", String cookies = ""});
  Future<dynamic> getPutApiResponse(String url, dynamic data, String token);
  Future deleteApi(String url, String token);
}
