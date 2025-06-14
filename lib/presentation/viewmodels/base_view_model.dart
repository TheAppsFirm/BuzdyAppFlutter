import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Base view model that provides loading and message handling utilities.
class BaseViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  void setLoading(bool value) {
    _isLoading = value;
    if (value) {
      EasyLoading.show();
    } else {
      EasyLoading.dismiss();
    }
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setMessage(String? message) {
    _infoMessage = message;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }
}
