import 'package:file_picker/file_picker.dart';
import 'package:intranet_graneros/app/core/constants/api_contants.dart';
import 'package:intranet_graneros/app/data/provider/api_provider.dart';
import 'package:intranet_graneros/app/data/models/document_model.dart';

class DocumentRepository {
  final ApiProvider _apiProvider;

  DocumentRepository(this._apiProvider);

  // Obtener documentos del departamento
  Future<List<DocumentModel>> getDocuments({
    String? category,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (category != null && category != 'all') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'page': page,
        'limit': limit,
      };

      final response = await _apiProvider.get(
        ApiConstants.documents,
        queryParameters: queryParams,
      );

      final List<dynamic> documentsData = response.data['documents'];
      return documentsData.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo documentos: $e');
      rethrow;
    }
  }

  // Subir un archivo
  Future<DocumentModel> uploadFile(
      PlatformFile file, Map<String, dynamic> metadata) async {
    try {
      final response = await _apiProvider.uploadFile(
        ApiConstants.uploadDocument,
        file.path!,
        data: metadata,
      );

      return DocumentModel.fromJson(response.data['document']);
    } catch (e) {
      print('Error subiendo archivo: $e');
      rethrow;
    }
  }

  // Subir múltiples archivos
  Future<List<DocumentModel>> uploadMultipleFiles(
      List<PlatformFile> files) async {
    try {
      final filePaths = files.map((file) => file.path!).toList();

      final response = await _apiProvider.uploadMultipleFiles(
        ApiConstants.uploadMultipleDocuments,
        filePaths,
        data: {
          'category': 'general',
          'description': 'Documentos subidos masivamente',
        },
      );

      final List<dynamic> documentsData = response.data['uploadedDocuments'];
      return documentsData.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error subiendo múltiples archivos: $e');
      rethrow;
    }
  }

  // Eliminar un documento
  Future<void> deleteDocument(String documentId) async {
    try {
      await _apiProvider.delete('${ApiConstants.deleteDocument}/$documentId');
    } catch (e) {
      print('Error eliminando documento: $e');
      rethrow;
    }
  }

  // Eliminar múltiples documentos
  Future<void> deleteMultipleDocuments(List<String> documentIds) async {
    try {
      await _apiProvider.post(
        ApiConstants.deleteMultipleDocuments,
        data: {'documentIds': documentIds},
      );
    } catch (e) {
      print('Error eliminando múltiples documentos: $e');
      rethrow;
    }
  }

  // Descargar documento
  Future<void> downloadDocument(DocumentModel document) async {
    try {
      await _apiProvider.downloadFile(
        '${ApiConstants.downloadDocument}/${document.id}',
        '/downloads/${document.name}',
      );
    } catch (e) {
      print('Error descargando documento: $e');
      rethrow;
    }
  }

  // Obtener documento por ID
  Future<DocumentModel?> getDocumentById(String documentId) async {
    try {
      final response =
          await _apiProvider.get('${ApiConstants.documents}/$documentId');
      return DocumentModel.fromJson(response.data);
    } catch (e) {
      print('Error obteniendo documento por ID: $e');
      return null;
    }
  }

  // Buscar documentos
  Future<List<DocumentModel>> searchDocuments(String query) async {
    try {
      final response = await _apiProvider.get(
        ApiConstants.documents,
        queryParameters: {'search': query},
      );

      final List<dynamic> documentsData = response.data['documents'];
      return documentsData.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error buscando documentos: $e');
      rethrow;
    }
  }

  // Obtener documentos por categoría
  Future<List<DocumentModel>> getDocumentsByCategory(String category) async {
    try {
      final response = await _apiProvider.get(
        ApiConstants.documentsByCategory,
        queryParameters: {'category': category},
      );

      final List<dynamic> documentsData = response.data;
      return documentsData.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo documentos por categoría: $e');
      rethrow;
    }
  }

  // Actualizar información del documento
  Future<DocumentModel> updateDocument(
      String documentId, Map<String, dynamic> data) async {
    try {
      final response = await _apiProvider.put(
        '${ApiConstants.documents}/$documentId',
        data: data,
      );

      return DocumentModel.fromJson(response.data);
    } catch (e) {
      print('Error actualizando documento: $e');
      rethrow;
    }
  }

  // Compartir documento
  Future<void> shareDocument(String documentId, List<String> userIds) async {
    try {
      await _apiProvider.post(
        '/documents/$documentId/share',
        data: {'userIds': userIds},
      );
    } catch (e) {
      print('Error compartiendo documento: $e');
      rethrow;
    }
  }

  // Marcar como favorito
  Future<void> toggleFavorite(String documentId, bool isFavorite) async {
    try {
      await _apiProvider.put(
        '/documents/$documentId/favorite',
        data: {'isFavorite': isFavorite},
      );
    } catch (e) {
      print('Error marcando favorito: $e');
      rethrow;
    }
  }
}
