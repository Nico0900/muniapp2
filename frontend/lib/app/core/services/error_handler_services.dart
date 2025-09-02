import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart' as dio; // Alias para Dio
import '../theme/app_theme.dart';
import 'storage_service.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unknown,
  fileUpload,
  permission,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final int? statusCode;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ErrorHandlerService extends GetxService {
  static ErrorHandlerService get instance => Get.find<ErrorHandlerService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<AppError> recentErrors = <AppError>[].obs;

  @override
  void onInit() {
    super.onInit();
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError(details.exception.toString(), details.stack.toString());
    };
  }

  // Manejo de errores Dio
  AppError handleDioError(dio.DioException error) {
    AppError appError;

    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        appError = AppError(
          type: ErrorType.network,
          message: 'Tiempo de conexión agotado. Verifica tu internet.',
          details: error.message,
        );
        break;

      case dio.DioExceptionType.badResponse:
        if (error.response != null) {
          appError = _handleHttpError(error.response!);
        } else {
          appError = AppError(
            type: ErrorType.server,
            message: 'Error de servidor desconocido',
            details: error.message,
          );
        }
        break;

      case dio.DioExceptionType.cancel:
        appError = AppError(
          type: ErrorType.network,
          message: 'Petición cancelada',
          details: error.message,
        );
        break;

      case dio.DioExceptionType.unknown:
        appError = AppError(
          type: ErrorType.network,
          message: 'Error de conexión. Verifica tu internet.',
          details: error.message,
        );
        break;

      default:
        appError = AppError(
          type: ErrorType.unknown,
          message: 'Error desconocido',
          details: error.message,
        );
    }

    _processError(appError);
    return appError;
  }

  // Manejo de errores HTTP
  AppError _handleHttpError(dio.Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message;
    ErrorType type;

    switch (statusCode) {
      case 400:
        type = ErrorType.validation;
        message = _extractErrorMessage(data) ?? 'Datos inválidos';
        break;

      case 401:
        type = ErrorType.authentication;
        message = 'Sesión expirada. Inicia sesión nuevamente.';
        _handleAuthenticationError();
        break;

      case 403:
        type = ErrorType.permission;
        message = 'No tienes permisos para realizar esta acción';
        break;

      case 404:
        type = ErrorType.server;
        message = 'Recurso no encontrado';
        break;

      case 422:
        type = ErrorType.validation;
        message =
            _extractValidationErrors(data) ?? 'Datos de validación incorrectos';
        break;

      case 429:
        type = ErrorType.server;
        message = 'Demasiadas peticiones. Intenta más tarde.';
        break;

      case 500:
      case 502:
      case 503:
      case 504:
        type = ErrorType.server;
        message = 'Error del servidor. Intenta más tarde.';
        break;

      default:
        type = ErrorType.server;
        message = _extractErrorMessage(data) ?? 'Error del servidor';
    }

    return AppError(
      type: type,
      message: message,
      statusCode: statusCode,
      details: data?.toString(),
    );
  }

  // Manejo errores generales
  AppError handleGeneralError(dynamic error, {String? context}) {
    if (error is dio.DioException) return handleDioError(error);

    final appError = AppError(
      type: ErrorType.unknown,
      message: error.toString(),
      details: context,
    );

    _processError(appError);
    return appError;
  }

  // Manejo errores de upload
  AppError handleFileUploadError(dynamic error, {String? fileName}) {
    String message = 'Error subiendo archivo';
    if (fileName != null) message = 'Error subiendo $fileName';

    if (error is dio.DioException) {
      if (error.response?.statusCode == 413) {
        message = 'El archivo es demasiado grande';
      } else if (error.response?.statusCode == 415) {
        message = 'Tipo de archivo no soportado';
      }
    }

    final appError = AppError(
      type: ErrorType.fileUpload,
      message: message,
      details: error.toString(),
    );

    _processError(appError);
    return appError;
  }

  // Mostrar error al usuario
  void showError(AppError error,
      {bool showToast = true, bool showDialog = false}) {
    if (showToast) _showErrorToast(error);
    if (showDialog) _showErrorDialog(error);
    _logError(error.message, error.details);
  }

  // Mostrar toast
  void _showErrorToast(AppError error) {
    Color backgroundColor;
    switch (error.type) {
      case ErrorType.network:
        backgroundColor = Colors.orange;
        break;
      case ErrorType.authentication:
        backgroundColor = Colors.red;
        break;
      case ErrorType.validation:
        backgroundColor = Colors.amber;
        break;
      case ErrorType.permission:
        backgroundColor = Colors.deepOrange;
        break;
      default:
        backgroundColor = AppTheme.errorColor;
    }

    Fluttertoast.showToast(
      msg: error.message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  // Mostrar diálogo
  void _showErrorDialog(AppError error) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: _getErrorColor(error.type)),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text('Detalles:',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              Text(error.details!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
          if (error.type == ErrorType.network)
            ElevatedButton(onPressed: () {}, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  void _processError(AppError error) {
    recentErrors.add(error);
    if (recentErrors.length > 50) recentErrors.removeAt(0);
    _logError(error.message, error.details);
  }

  void _handleAuthenticationError() {
    _storageService.clearAll();
    Get.offAllNamed('/login');
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }

  String? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is List)
        return errors.map((e) => e['msg'] ?? e.toString()).join(', ');
      if (errors is Map) return errors.values.join(', ');
    }
    return _extractErrorMessage(data);
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.fileUpload:
        return Icons.upload_file;
      default:
        return Icons.error;
    }
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.permission:
        return Colors.deepOrange;
      default:
        return AppTheme.errorColor;
    }
  }

  void _logError(String message, String? details) {
    print('🔥 ERROR: $message');
    if (details != null) print('📋 DETAILS: $details');
    print('⏰ TIME: ${DateTime.now()}');
    print('━' * 50);
  }

  void clearErrors() => recentErrors.clear();

  Map<ErrorType, int> getErrorStats() {
    final stats = <ErrorType, int>{};
    for (final error in recentErrors) {
      stats[error.type] = (stats[error.type] ?? 0) + 1;
    }
    return stats;
  }
}
