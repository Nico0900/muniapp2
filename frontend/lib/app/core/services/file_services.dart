import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  // Tipos de archivos permitidos
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt'
  ];

  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp'
  ];

  // Tamaño máximo de archivo (50MB)
  static const int maxFileSize = 50 * 1024 * 1024;

  // Seleccionar un archivo
  Future<PlatformFile?> pickSingleFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: kIsWeb, // Solo cargar datos en web
        withReadStream: !kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validar tamaño
        if (file.size > maxFileSize) {
          throw Exception(
              'El archivo es demasiado grande. Máximo permitido: 50MB');
        }

        // Validar tipo de archivo
        if (allowedExtensions != null && file.extension != null) {
          if (!allowedExtensions.contains(file.extension!.toLowerCase())) {
            throw Exception('Tipo de archivo no permitido');
          }
        }

        return file;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Seleccionar múltiples archivos
  Future<List<PlatformFile>?> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        // Validar cada archivo
        for (final file in result.files) {
          if (file.size > maxFileSize) {
            throw Exception(
                'El archivo ${file.name} es demasiado grande. Máximo permitido: 50MB');
          }

          if (allowedExtensions != null && file.extension != null) {
            if (!allowedExtensions.contains(file.extension!.toLowerCase())) {
              throw Exception('Tipo de archivo no permitido: ${file.name}');
            }
          }
        }

        return result.files;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Seleccionar documentos
  Future<List<PlatformFile>?> pickDocuments({bool multiple = true}) async {
    return await pickMultipleFiles(
      allowedExtensions: allowedDocumentTypes,
      type: FileType.custom,
    );
  }

  // Seleccionar imágenes
  Future<List<PlatformFile>?> pickImages({bool multiple = true}) async {
    return await pickMultipleFiles(
      allowedExtensions: allowedImageTypes,
      type: FileType.custom,
    );
  }

  // Obtener directorio de documentos
  Future<Directory> getDocumentsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('No soportado en web');
    }
    return await getApplicationDocumentsDirectory();
  }

  // Obtener directorio temporal
  Future<Directory> getTempDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('No soportado en web');
    }
    return await getTemporaryDirectory();
  }

  // Crear directorio si no existe
  Future<Directory> createDirectory(String path) async {
    if (kIsWeb) {
      throw UnsupportedError('No soportado en web');
    }

    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  // Guardar archivo
  Future<File> saveFile(PlatformFile platformFile, String path) async {
    if (kIsWeb) {
      throw UnsupportedError('No soportado en web');
    }

    final file = File(path);

    if (platformFile.path != null) {
      // Copiar desde el path original
      final originalFile = File(platformFile.path!);
      await originalFile.copy(path);
    } else if (platformFile.bytes != null) {
      // Escribir desde bytes
      await file.writeAsBytes(platformFile.bytes!);
    }

    return file;
  }

  // Eliminar archivo
  Future<bool> deleteFile(String path) async {
    try {
      if (kIsWeb) {
        return false; // No se puede eliminar archivos en web
      }

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error eliminando archivo: $e');
    }
    return false;
  }

  // Obtener información del archivo
  Map<String, dynamic> getFileInfo(PlatformFile file) {
    return {
      'name': file.name,
      'size': file.size,
      'extension': file.extension,
      'path': file.path,
      'sizeFormatted': formatFileSize(file.size),
    };
  }

  // Formatear tamaño de archivo
  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Validar tipo de archivo
  bool isValidFileType(String? extension, List<String> allowedTypes) {
    if (extension == null) return false;
    return allowedTypes.contains(extension.toLowerCase());
  }

  // Obtener icono según tipo de archivo
  String getFileTypeIcon(String? extension) {
    if (extension == null) return 'file';

    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'image';
      case 'txt':
        return 'text';
      case 'zip':
      case 'rar':
      case '7z':
        return 'archive';
      default:
        return 'file';
    }
  }
}
