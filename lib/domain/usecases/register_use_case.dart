import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  
  Future<User> execute(Map<String, String> payload) {
    return repository.register(payload);
  }
}
