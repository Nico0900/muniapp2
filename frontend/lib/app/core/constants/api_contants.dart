class ApiConstants {
  ApiConstants._();

  // Base URL - Cambiar por la URL de tu backend
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Document endpoints
  static const String documents = '/documents';
  static const String uploadDocument = '/documents/upload';
  static const String uploadMultipleDocuments = '/documents/upload-multiple';
  static const String deleteDocument = '/documents';
  static const String deleteMultipleDocuments = '/documents/delete-multiple';
  static const String downloadDocument = '/documents/download';
  static const String documentsByDepartment = '/documents/department';
  static const String documentsByCategory = '/documents/category';

  // Department endpoints
  static const String departments = '/departments';
  static const String departmentUsers = '/departments/users';
  static const String departmentDocuments = '/departments/documents';

  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String recentActivity = '/dashboard/activity';
  static const String notifications = '/dashboard/notifications';

  // System endpoints
  static const String systemInfo = '/system/info';
  static const String systemHealth = '/system/health';
}