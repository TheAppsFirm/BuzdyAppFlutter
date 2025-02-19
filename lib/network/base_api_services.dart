abstract class BaseApiServices {
  String getBaseURL();
  String getAllBankEndPoint({pageNumber});
  String getRegistrationEndPoint();
  String updateProfile();
  String getLoginEndPoint();
  String getRegisterEndPoint();

  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getPostApiResponse(String url, dynamic data,
      {String token = "", String cookies = ""});
  Future<dynamic> getPutApiResponse(String url, dynamic data, String token);
  Future deleteApi(String url, String token);
}
