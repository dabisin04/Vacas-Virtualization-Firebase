import '../entities/user.dart';

abstract class UserRepository {
  Future<void> createUser(Usuario user);
  Future<void> updateUser(Usuario user);
  Future<void> deleteUser(String id);
  Future<Usuario?> getUserById(String id);
  Future<List<Usuario>> getAllUsers();
  Future<List<Usuario>> getUsersByFinca(String farmId);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<Usuario?> getCurrentSession();
  Future<bool> isLoggedIn();
  Future<void> syncWithServer();
}
