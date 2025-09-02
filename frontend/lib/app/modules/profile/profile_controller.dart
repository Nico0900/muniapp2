import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intranet_graneros/app/data/models/users_models.dart';

import '../../data/repositories/auth_repository.dart';
import '../../core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Change password controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    currentUser.value = _authRepository.currentUser;
    if (currentUser.value != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final user = currentUser.value!;
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.phone ?? '';
  }

  // Validaciones
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    if (value.trim().length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
        return 'Formato de teléfono inválido';
      }
    }
    return null;
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña actual es requerida';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma la nueva contraseña';
    }
    if (value != newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Actualizar perfil
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final updatedUser = await _authRepository.updateProfile({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      if (updatedUser != null) {
        currentUser.value = updatedUser;
        _showSuccessMessage('Perfil actualizado correctamente');
      } else {
        _showErrorMessage('Error al actualizar el perfil');
      }
    } catch (e) {
      _showErrorMessage('Error al actualizar el perfil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Resetear formulario
  void resetForm() {
    _populateForm();
  }

  // Mostrar diálogo de cambio de contraseña
  void showChangePasswordDialog() {
    // Limpiar campos
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isNewPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;

    Get.dialog(
      AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => TextFormField(
                    controller: currentPasswordController,
                    obscureText: !isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => isPasswordVisible.toggle(),
                      ),
                    ),
                    validator: validateCurrentPassword,
                  )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                    controller: newPasswordController,
                    obscureText: !isNewPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => isNewPasswordVisible.toggle(),
                      ),
                    ),
                    validator: validateNewPassword,
                  )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => isConfirmPasswordVisible.toggle(),
                      ),
                    ),
                    validator: validateConfirmPassword,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
                onPressed: isLoading.value ? null : _changePassword,
                child: isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cambiar Contraseña'),
              )),
        ],
      ),
    );
  }

  // Cambiar contraseña
  Future<void> _changePassword() async {
    // Validar campos manualmente ya que no están en un Form
    final currentError =
        validateCurrentPassword(currentPasswordController.text);
    final newError = validateNewPassword(newPasswordController.text);
    final confirmError =
        validateConfirmPassword(confirmPasswordController.text);

    if (currentError != null || newError != null || confirmError != null) {
      _showErrorMessage('Por favor, corrige los errores en el formulario');
      return;
    }

    try {
      isLoading.value = true;

      final success = await _authRepository.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );

      if (success) {
        Get.back(); // Cerrar diálogo
        _showSuccessMessage('Contraseña cambiada correctamente');
      } else {
        _showErrorMessage('Error al cambiar la contraseña');
      }
    } catch (e) {
      String errorMessage = 'Error al cambiar la contraseña';

      if (e.toString().contains('current')) {
        errorMessage = 'La contraseña actual es incorrecta';
      }

      _showErrorMessage(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Desactivar cuenta
  void deactivateAccount() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar Desactivación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que deseas desactivar tu cuenta?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text('• Deshabilitará tu acceso al sistema'),
            const Text('• Mantendrá tus documentos guardados'),
            const Text('• Puede ser revertida por un administrador'),
            const SizedBox(height: 16),
            const Text(
              'Para continuar, escribe "DESACTIVAR" a continuación:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'DESACTIVAR',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Aquí podrías validar la entrada
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showInfoMessage('Función disponible próximamente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  // Toggle password visibility
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // Mensajes
  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successColor,
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.errorColor,
      textColor: Colors.white,
    );
  }

  void _showInfoMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.infoColor,
      textColor: Colors.white,
    );
  }
}
