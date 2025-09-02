import 'package:dio/dio.dart' as dio; // Alias para Dio
import 'package:get/get.dart';
import '../../core/constants/api_contants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/error_handler_services.dart';

class ApiProvider {
  late dio.Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  // Getter para el error handler
  ErrorHandlerService? get _errorHandler {
    try {
      return Get.find<ErrorHandlerService>();
    } catch (_) {
      return null;
    }
  }

  ApiProvider() {
    _dio = dio.Dio();
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print(
              '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          _errorHandler?.handleDioError(error);
          handler.next(error);
        },
      ),
    );

    _dio.options.connectTimeout = const Duration(milliseconds: 15000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 15000);
    _dio.options.sendTimeout = const Duration(milliseconds: 15000);
  }

  void _handleUnauthorized() {
    _storageService.clearAll();
    Get.offAllNamed('/login');
  }

  // GET
  Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(
        '${ApiConstants.baseUrl}$path',
        queryParameters: queryParameters,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleDioError(e);
      rethrow;
    }
  }

  // POST
  Future<dio.Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(
        '${ApiConstants.baseUrl}$path',
        data: data,
        queryParameters: queryParameters,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleDioError(e);
      rethrow;
    }
  }

  // PUT
  Future<dio.Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(
        '${ApiConstants.baseUrl}$path',
        data: data,
        queryParameters: queryParameters,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleDioError(e);
      rethrow;
    }
  }

  // DELETE
  Future<dio.Response> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(
        '${ApiConstants.baseUrl}$path',
        queryParameters: queryParameters,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleDioError(e);
      rethrow;
    }
  }

  // Upload single file
  Future<dio.Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = dio.FormData();

      formData.files.add(
        MapEntry('file', await dio.MultipartFile.fromFile(filePath)),
      );

      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return await _dio.post(
        '${ApiConstants.baseUrl}$path',
        data: formData,
        options: dio.Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onProgress,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleFileUploadError(e,
          fileName: filePath.split('/').last);
      rethrow;
    }
  }

  // Upload multiple files
  Future<dio.Response> uploadMultipleFiles(
    String path,
    List<String> filePaths, {
    Map<String, dynamic>? data,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = dio.FormData();

      for (final path in filePaths) {
        formData.files.add(
          MapEntry('files', await dio.MultipartFile.fromFile(path)),
        );
      }

      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return await _dio.post(
        '${ApiConstants.baseUrl}$path',
        data: formData,
        options: dio.Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: onProgress,
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleFileUploadError(e,
          fileName: '${filePaths.length} archivos');
      rethrow;
    }
  }

  // Download
  Future<dio.Response> downloadFile(
    String path,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        '${ApiConstants.baseUrl}$path',
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: dio.Options(receiveTimeout: const Duration(minutes: 10)),
      );
    } on dio.DioException catch (e) {
      _errorHandler?.handleDioError(e);
      rethrow;
    }
  }

  // Cancel requests
  void cancelAllRequests() {
    _dio.close(force: true); // Reemplaza clear() que no existe
  }

  Map<String, dynamic> getConnectionStats() {
    return {
      'connectTimeout': _dio.options.connectTimeout?.inMilliseconds,
      'receiveTimeout': _dio.options.receiveTimeout?.inMilliseconds,
      'sendTimeout': _dio.options.sendTimeout?.inMilliseconds,
      'baseUrl': ApiConstants.baseUrl,
      'hasToken': _storageService.hasToken,
    };
  }
}
