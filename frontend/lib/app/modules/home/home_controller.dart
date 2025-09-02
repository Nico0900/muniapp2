import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intranet_graneros/app/data/models/users_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class NavigationItem {
  final IconData icon;
  final String title;

  NavigationItem({required this.icon, required this.title});
}

class HomeController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  final RxInt selectedIndex = 0.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final List<NavigationItem> navigationItems = [
    NavigationItem(icon: Icons.dashboard_outlined, title: 'Dashboard'),
    NavigationItem(icon: Icons.folder_outlined, title: 'Documentos'),
    NavigationItem(icon: Icons.person_outlined, title: 'Perfil'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    currentUser.value = _authRepository.currentUser;
  }

  void changeTab(int index) {
    if (index >= 0 && index < navigationItems.length) {
      selectedIndex.value = index;
    }
  }

  void showNotifications() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Notificaciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              icon: Icons.info,
              title: 'Sistema actualizado',
              subtitle: 'Nueva versión disponible',
              time: 'Hace 2 horas',
            ),
            const Divider(),
            _buildNotificationItem(
              icon: Icons.document_scanner,
              title: 'Documento aprobado',
              subtitle: 'Proyecto_Municipal_2024.pdf',
              time: 'Hace 5 horas',
            ),
            const Divider(),
            _buildNotificationItem(
              icon: Icons.group,
              title: 'Reunión programada',
              subtitle: 'Mañana a las 10:00 AM',
              time: 'Hace 1 día',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navegar a página completa de notificaciones
            },
            child: const Text('Ver todas'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void showMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Get.back();
                showSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda'),
              onTap: () {
                Get.back();
                showHelp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                Get.back();
                showAbout();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Configuración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Notificaciones push'),
              subtitle: const Text('Recibir notificaciones en tiempo real'),
              value: true,
              onChanged: (value) {
                // Implementar configuración
              },
            ),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Cambiar tema de la aplicación'),
              value: false,
              onChanged: (value) {
                // Implementar cambio de tema
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
              _showSuccessMessage('Configuración guardada');
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo usar la aplicación?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Dashboard: Ve estadísticas y actividad reciente'),
              Text('2. Documentos: Sube, descarga y gestiona archivos'),
              Text('3. Perfil: Actualiza tu información personal'),
              SizedBox(height: 16),
              Text(
                'Soporte técnico:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('📧 soporte@municipalidad.gob.cl'),
              Text('📞 +56 2 1234 5678'),
              Text('🌐 www.municipalidad.gob.cl/soporte'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Acerca de'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Intranet Municipal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Versión 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Sistema de gestión documental para jefes de departamento municipales.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 Municipalidad\nTodos los derechos reservados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar salida'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _authRepository.logout();
        _showSuccessMessage('Sesión cerrada correctamente');
        Get.offAllNamed(AppRoutes.LOGIN);
      } catch (e) {
        _showErrorMessage('Error al cerrar sesión');
      }
    }
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
