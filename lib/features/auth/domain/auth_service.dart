import '../data/auth_repository.dart';
import 'user_model.dart';

// Layer 2 (domain). Business rules for logging in.
class AuthService {
  final AuthRepository _repository = AuthRepository();

  // Returns the user, or throws an error message if login fails.
  Future<UserModel> login(String email, String password) async {
    UserModel? user = await _repository.login(
      email.trim().toLowerCase(),
      password,
    );
    if (user == null) {
      throw 'Invalid email or password';
    }
    return user;
  }
}
