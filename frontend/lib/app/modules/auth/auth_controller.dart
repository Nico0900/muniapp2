import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Verificar si el usuario ya está autenticado
  void _checkAuthStatus() {
    if (_authRepository.isLoggedIn) {
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Validar email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    if (!GetUtils.isEmail(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    // Validar dominio municipal (opcional)
    if (!value.endsWith('@municipalidad.gob.cl') &&
        !value.endsWith('@admin.cl')) {
      return 'Debe usar un correo institucional';
    }

    return null;
  }

  // Validar password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  // Login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      emailError.value = '';
      passwordError.value = '';

      final success = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        _showSuccessMessage('Sesión iniciada correctamente');
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        _showErrorMessage('Credenciales incorrectas');
      }
    } catch (e) {
      _handleLoginError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Manejar errores de login
  void _handleLoginError(String error) {
    if (error.contains('email')) {
      emailError.value = 'Correo electrónico inválido';
    } else if (error.contains('password')) {
      passwordError.value = 'Contraseña incorrecta';
    } else if (error.contains('network')) {
      _showErrorMessage('Error de conexión. Verifica tu internet.');
    } else if (error.contains('server')) {
      _showErrorMessage('Error del servidor. Intenta más tarde.');
    } else if (error.contains('unauthorized')) {
      _showErrorMessage('Usuario no autorizado');
    } else {
      _showErrorMessage('Error desconocido. Intenta nuevamente.');
    }
  }

  // Forgot password
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showWarningMessage('Ingresa tu correo electrónico primero');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showWarningMessage('Ingresa un correo electrónico válido');
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.forgotPassword(email);

      _showSuccessMessage('Se enviaron las instrucciones a tu correo');
    } catch (e) {
      _showErrorMessage('Error al enviar correo de recuperación');
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      Get.offAllNamed(AppRoutes.LOGIN);
      _showSuccessMessage('Sesión cerrada correctamente');
    } catch (e) {
      _showErrorMessage('Error al cerrar sesión');
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // Show error message
  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // Show warning message
  void _showWarningMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  // Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
  }

  // Auto-fill for development (remover en producción)
  void autoFillDevelopment() {
    emailController.text = 'admin@municipalidad.gob.cl';
    passwordController.text = '123456';
  }
}
