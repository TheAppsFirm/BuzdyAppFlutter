import 'package:buzdy/domain/entities/user.dart';
import 'package:buzdy/domain/repositories/auth_repository.dart';
import '../network/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  AuthRepositoryImpl({required this.apiService});
  
  @override
  Future<User> login(String email, String password) async {
    final response = await apiService.post("/users/signin", {
      "email": email,
      "password": password,
    });
    return User(
      id: response['id'],
      firstName: response['firstname'],
      lastName: response['lastname'],
      email: response['email'],
      token: response['token'],
    );
  }
  
  @override
  Future<User> register(Map<String, String> payload) async {
    final response = await apiService.post("/users/signup", payload);
    return User(
      id: response['id'],
      firstName: response['firstname'],
      lastName: response['lastname'],
      email: response['email'],
      token: response['token'],
    );
  }
}
