import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';
import '../../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  RouteSettings? redirect(String? route) {
    // Lista de rutas que no requieren autenticación
    final publicRoutes = [
      AppRoutes.SPLASH,
      AppRoutes.LOGIN,
    ];

    // Si es una ruta pública, permitir acceso
    if (publicRoutes.contains(route)) {
      return null;
    }

    // Verificar si el usuario está autenticado
    if (!_storageService.hasToken) {
      // Redirigir al login si no está autenticado
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // Verificar si el token ha expirado (implementación opcional)
    if (_isTokenExpired()) {
      _storageService.clearAll();
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // Permitir acceso si está autenticado
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    // Log de navegación para debugging
    print('Navegando a: ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    // Inicializar bindings adicionales si es necesario
    return super.onBindingsStart(bindings);
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    // Ejecutar lógica antes de construir la página
    return super.onPageBuildStart(page);
  }

  // Verificar si el token ha expirado (implementación básica)
  bool _isTokenExpired() {
    try {
      final token = _storageService.getToken();
      if (token == null) return true;

      // Decodificar JWT y verificar expiración
      // Esta es una implementación básica, en producción usarías una librería JWT
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Por ahora, asumimos que el token es válido
      // En una implementación real, decodificarías el payload y verificarías 'exp'
      return false;
    } catch (e) {
      print('Error verificando token: $e');
      return true;
    }
  }
}

// Middleware específico para rutas de admin (opcional)
class AdminMiddleware extends GetMiddleware {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  RouteSettings? redirect(String? route) {
    // Verificar autenticación primero
    if (!_storageService.hasToken) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // Verificar rol de administrador
    final userData = _storageService.getUser();
    if (userData == null || userData['role'] != 'admin') {
      // Redirigir al dashboard si no es admin
      return const RouteSettings(name: AppRoutes.DASHBOARD);
    }

    return null;
  }
}

// Middleware para rutas públicas (fuerza logout si está autenticado)
class PublicMiddleware extends GetMiddleware {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  RouteSettings? redirect(String? route) {
    // Si el usuario ya está autenticado y trata de acceder al login,
    // redirigir al home
    if (route == AppRoutes.LOGIN && _storageService.hasToken) {
      return const RouteSettings(name: AppRoutes.HOME);
    }

    return null;
  }
}
