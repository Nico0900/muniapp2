import 'package:get/get.dart';
import 'package:intranet_graneros/app/core/constants/api_contants.dart';
import 'package:intranet_graneros/app/data/models/users_models.dart';
import 'package:intranet_graneros/app/data/provider/api_provider.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {
  final ApiProvider _apiProvider;
  final StorageService _storageService = Get.find();

  AuthRepository(this._apiProvider);

  // Verificar si el usuario está logueado
  bool get isLoggedIn => _storageService.hasToken;

  // Obtener usuario actual
  UserModel? get currentUser {
    final userData = _storageService.getUser();
    return userData != null ? UserModel.fromJson(userData) : null;
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiProvider.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Guardar token
        await _storageService.saveToken(data['token']);
        
        // Guardar usuario
        await _storageService.saveUser(data['user']);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Llamar al endpoint de logout (opcional)
      if (_storageService.hasToken) {
        await _apiProvider.post(ApiConstants.logout);
      }
    } catch (e) {
      print('Error en logout: $e');
    } finally {
      // Limpiar datos locales siempre
      await _storageService.clearAll();
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiProvider.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      print('Error en forgot password: $e');
      rethrow;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiProvider.post(ApiConstants.refresh);
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _storageService.saveToken(data['token']);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error en refresh token: $e');
      await logout(); // Si falla el refresh, cerrar sesión
      return false;
    }
  }

  // Get profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiProvider.get(ApiConstants.profile);
      
      if (response.statusCode == 200) {
        final userData = response.data;
        await _storageService.saveUser(userData);
        return UserModel.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo perfil: $e');
      rethrow;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiProvider.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cambiando contraseña: $e');
      rethrow;
    }
  }

  // Update profile
  Future<UserModel?> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _apiProvider.put(
        ApiConstants.updateProfile,
        data: userData,
      );

      if (response.statusCode == 200) {
        final updatedUser = response.data;
        await _storageService.saveUser(updatedUser);
        return UserModel.fromJson(updatedUser);
      }

      return null;
    } catch (e) {
      print('Error actualizando perfil: $e');
      rethrow;
    }
  }
}