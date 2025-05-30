import 'package:vacas/domain/entities/user.dart';
import 'package:vacas/domain/repositories/user_repository.dart';

class UserRepositoryHybrid implements UserRepository {
  final UserRepository localRepository;
  final UserRepository firebaseRepository;

  UserRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> createUser(Usuario user) async {
    await Future.wait([
      firebaseRepository.createUser(user),
    ]);
  }

  @override
  Future<void> updateUser(Usuario user) async {
    await Future.wait([
      localRepository.updateUser(user),
      firebaseRepository.updateUser(user),
    ]);
  }

  @override
  Future<void> deleteUser(String id) async {
    await Future.wait([
      localRepository.deleteUser(id),
      firebaseRepository.deleteUser(id),
    ]);
  }

  @override
  Future<Usuario?> getUserById(String id) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getUserById(id);
  }

  @override
  Future<List<Usuario>> getAllUsers() async {
    return await localRepository.getAllUsers();
  }

  @override
  Future<List<Usuario>> getUsersByFinca(String farmId) async {
    return await localRepository.getUsersByFinca(farmId);
  }

  @override
  Future<void> login(String email, String password) async {
    await Future.wait([
      localRepository.login(email, password),
      firebaseRepository.login(email, password),
    ]);
  }

  @override
  Future<void> logout() async {
    await Future.wait([
      localRepository.logout(),
      firebaseRepository.logout(),
    ]);
  }

  @override
  Future<Usuario?> getCurrentSession() async {
    return await localRepository.getCurrentSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localRepository.isLoggedIn();
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
