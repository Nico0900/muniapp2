import 'package:intranet_graneros/app/core/constants/api_contants.dart';
import 'package:intranet_graneros/app/data/provider/api_provider.dart';
import '../models/activity_model.dart';

class DashboardRepository {
  final ApiProvider _apiProvider;

  DashboardRepository(this._apiProvider);

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiProvider.get(ApiConstants.dashboardStats);
      return response.data;
    } catch (e) {
      throw Exception('Error loading statistics: $e');
    }
  }

  Future<List<ActivityModel>> getRecentActivity() async {
    try {
      final response = await _apiProvider.get(ApiConstants.recentActivity);
      final List<dynamic> data = response.data;
      return data.map((json) => ActivityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading recent activity: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _apiProvider.get(ApiConstants.notifications);
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }
}
