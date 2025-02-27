class AppException implements Exception {
  final dynamic message;
  final dynamic prefix;
  AppException([this.message, this.prefix]);
  @override
  String toString() {
    return "\$prefix\$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message]) : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message]) : super(message, "Unauthorised: ");
}

class NoInternetException extends AppException {
  NoInternetException([String? message]) : super(message, "No Internet Connection: ");
}
