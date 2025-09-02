import 'package:get/get.dart';
import 'package:intranet_graneros/app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find();
  final RxString loadingMessage = 'Inicializando...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simular tiempo de carga
      loadingMessage.value = 'Verificando autenticación...';
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verificar si el usuario está autenticado
      final hasToken = _storageService.hasToken;
      
      if (hasToken) {
        loadingMessage.value = 'Cargando datos del usuario...';
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Verificar si el token es válido (en una implementación real)
        // Por ahora asumimos que es válido si existe
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        loadingMessage.value = 'Preparando interfaz...';
        await Future.delayed(const Duration(milliseconds: 1000));
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      // En caso de error, ir al login
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}