import 'package:get/get.dart';
import 'package:intranet_graneros/app/data/models/users_models.dart';

import '../../data/models/activity_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final DashboardRepository _dashboardRepository = Get.find();

  // Usuario actual
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Estadísticas
  final RxInt totalDocuments = 0.obs;
  final RxInt documentsThisMonth = 0.obs;
  final RxInt totalDownloads = 0.obs;
  final RxString storageUsed = '0 GB'.obs;

  // Tendencias
  final RxString documentsTrend = '+0%'.obs;
  final RxString monthlyTrend = '+0%'.obs;
  final RxString downloadsTrend = '+0%'.obs;
  final RxString storageTrend = '+0%'.obs;

  // Actividad reciente
  final RxList<ActivityModel> recentActivities = <ActivityModel>[].obs;
  final RxBool isLoadingActivity = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadDashboardData();
  }

  void _loadUserData() {
    currentUser.value = _authRepository.currentUser;
  }

  Future<void> _loadDashboardData() async {
    try {
      await Future.wait([
        _loadStatistics(),
        _loadRecentActivity(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _dashboardRepository.getStatistics();

      totalDocuments.value = stats['totalDocuments'] ?? 0;
      documentsThisMonth.value = stats['documentsThisMonth'] ?? 0;
      totalDownloads.value = stats['totalDownloads'] ?? 0;
      storageUsed.value = _formatStorage(stats['storageUsed'] ?? 0);

      // Calcular tendencias (simulado)
      documentsTrend.value = _calculateTrend(
          stats['documentsLastMonth'], stats['documentsThisMonth']);
      monthlyTrend.value = _calculateTrend(
          stats['documentsLastMonth'], stats['documentsThisMonth']);
      downloadsTrend.value =
          _calculateTrend(stats['downloadsLastMonth'], stats['totalDownloads']);
      storageTrend.value = '+15%'; // Simulado
    } catch (e) {
      print('Error loading statistics: $e');
      // Datos de ejemplo si falla la carga
      _loadMockStatistics();
    }
  }

  void _loadMockStatistics() {
    totalDocuments.value = 247;
    documentsThisMonth.value = 18;
    totalDownloads.value = 1234;
    storageUsed.value = '2.4 GB';

    documentsTrend.value = '+12%';
    monthlyTrend.value = '+8%';
    downloadsTrend.value = '+15%';
    storageTrend.value = '+5%';
  }

  Future<void> _loadRecentActivity() async {
    try {
      isLoadingActivity.value = true;
      final activities = await _dashboardRepository.getRecentActivity();
      recentActivities.value = activities;
    } catch (e) {
      print('Error loading recent activity: $e');
      // Datos de ejemplo si falla la carga
      _loadMockActivity();
    } finally {
      isLoadingActivity.value = false;
    }
  }

  void _loadMockActivity() {
    recentActivities.value = [
      ActivityModel(
        id: '1',
        type: ActivityType.upload,
        title: 'Documento subido',
        description: 'Presupuesto_2024.pdf',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: currentUser.value?.id ?? '',
        userName: currentUser.value?.fullName ?? 'Usuario',
      ),
      ActivityModel(
        id: '2',
        type: ActivityType.download,
        title: 'Documento descargado',
        description: 'Informe_Mensual.docx',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        userId: currentUser.value?.id ?? '',
        userName: 'Juan Pérez',
      ),
      ActivityModel(
        id: '3',
        type: ActivityType.delete,
        title: 'Documento eliminado',
        description: 'Archivo_temporal.txt',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        userId: currentUser.value?.id ?? '',
        userName: currentUser.value?.fullName ?? 'Usuario',
      ),
      ActivityModel(
        id: '4',
        type: ActivityType.share,
        title: 'Documento compartido',
        description: 'Proyecto_Obras.pdf',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        userId: currentUser.value?.id ?? '',
        userName: 'María González',
      ),
    ];
  }

  String _formatStorage(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _calculateTrend(int? previous, int? current) {
    if (previous == null || current == null || previous == 0) {
      return '+0%';
    }

    final percentage = ((current - previous) / previous * 100).round();
    return percentage >= 0 ? '+$percentage%' : '$percentage%';
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  // Acciones rápidas
  void uploadDocument() {
    Get.toNamed(AppRoutes.DOCUMENTS);
    // Aquí podrías activar directamente el modal de upload
  }

  void viewDocuments() {
    Get.toNamed(AppRoutes.DOCUMENTS);
  }

  void openProfile() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  void viewReports() {
    Get.snackbar(
      'Reportes',
      'Función en desarrollo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Refresh
  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  Future<void> refreshActivity() async {
    await _loadRecentActivity();
  }
}
