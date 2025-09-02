import 'package:intranet_graneros/app/core/constants/api_contants.dart';
import 'package:intranet_graneros/app/data/models/users_models.dart';
import 'package:intranet_graneros/app/data/provider/api_provider.dart';


class UserRepository {
  final ApiProvider _apiProvider;

  UserRepository(this._apiProvider);

  // Obtener todos los usuarios del departamento
  Future<List<UserModel>> getUsers({
    String? departmentId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (departmentId != null) 'departmentId': departmentId,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      };

      final response = await _apiProvider.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      final List<dynamic> usersData = response.data['users'];
      return usersData.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      rethrow;
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _apiProvider.get('${ApiConstants.users}/$userId');
      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Actualizar usuario
  Future<UserModel> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiProvider.put(
        '${ApiConstants.users}/$userId',
        data: userData,
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Error actualizando usuario: $e');
      rethrow;
    }
  }

  // Crear nuevo usuario (solo admin)
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiProvider.post(
        ApiConstants.users,
        data: userData,
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Error creando usuario: $e');
      rethrow;
    }
  }

  // Eliminar usuario (solo admin)
  Future<void> deleteUser(String userId) async {
    try {
      await _apiProvider.delete('${ApiConstants.users}/$userId');
    } catch (e) {
      print('Error eliminando usuario: $e');
      rethrow;
    }
  }

  // Activar/desactivar usuario
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _apiProvider.put(
        '${ApiConstants.users}/$userId/status',
        data: {'isActive': isActive},
      );
    } catch (e) {
      print('Error cambiando estado del usuario: $e');
      rethrow;
    }
  }

  // Obtener perfil del usuario actual
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final response = await _apiProvider.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Error obteniendo perfil del usuario: $e');
      return null;
    }
  }

  // Buscar usuarios
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _apiProvider.get(
        ApiConstants.users,
        queryParameters: {'search': query},
      );

      final List<dynamic> usersData = response.data['users'];
      return usersData.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error buscando usuarios: $e');
      rethrow;
    }
  }

  // Obtener usuarios por departamento
  Future<List<UserModel>> getUsersByDepartment(String departmentId) async {
    try {
      final response = await _apiProvider.get(
        ApiConstants.departmentUsers,
        queryParameters: {'departmentId': departmentId},
      );

      final List<dynamic> usersData = response.data;
      return usersData.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo usuarios por departamento: $e');
      rethrow;
    }
  }

  // Cambiar rol del usuario (solo admin)
  Future<void> changeUserRole(String userId, String newRole) async {
    try {
      await _apiProvider.put(
        '${ApiConstants.users}/$userId/role',
        data: {'role': newRole},
      );
    } catch (e) {
      print('Error cambiando rol del usuario: $e');
      rethrow;
    }
  }
}
