import 'package:get/get.dart';
import 'package:intranet_graneros/app/core/services/error_handler_services.dart';
import 'package:intranet_graneros/app/core/services/file_services.dart';
import 'package:intranet_graneros/app/data/provider/api_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../services/storage_service.dart';

class DependencyInjection {
  static void init() {
    // Servicios core (deben inicializarse primero)
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ErrorHandlerService>(ErrorHandlerService(), permanent: true);
    Get.lazyPut<FileService>(() => FileService(), fenix: true);
    
    // Providers (dependen de servicios)
    Get.lazyPut<ApiProvider>(() => ApiProvider(), fenix: true);
    
    // Repositorios (dependen de providers)
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut<DocumentRepository>(() => DocumentRepository(Get.find()), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(Get.find()), fenix: true);
  }
}