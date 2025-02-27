import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

class ApiService {
  final String baseUrl = "https://api.buzdy.com";

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse(baseUrl + endpoint);
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      return _processResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on Exception catch (e) {
      throw FetchDataException('Error: \$e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {String token = ""}) async {
    final url = Uri.parse(baseUrl + endpoint);
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': "Bearer \$token",
    };
    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));
      return _processResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on Exception catch (e) {
      throw FetchDataException('Error: \$e');
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException();
      case 401:
        throw UnauthorisedException();
      case 500:
        throw FetchDataException();
      default:
        throw FetchDataException('Error occurred: \${response.body}');
    }
  }
}
