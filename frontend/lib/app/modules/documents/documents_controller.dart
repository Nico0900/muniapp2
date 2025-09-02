import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intranet_graneros/app/core/services/file_services.dart';
import 'package:intranet_graneros/app/data/models/document_model.dart';
import 'package:intranet_graneros/app/data/repositories/document_repository.dart';

enum ViewMode { grid, list }

enum SortBy { name, date, size, type }

class DocumentsController extends GetxController {
  final DocumentRepository _documentRepository = Get.find();
  final FileService _fileService = Get.find();

  // Observables
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxList<DocumentModel> filteredDocuments = <DocumentModel>[].obs;
  final RxList<String> selectedDocuments = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxInt totalDocuments = 0.obs;
  final Rx<ViewMode> viewMode = ViewMode.grid.obs;
  final Rx<SortBy> sortBy = SortBy.date.obs;
  final RxBool sortAscending = false.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final RxDouble minSize = 0.0.obs;
  final RxDouble maxSize = double.infinity.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();

    // Escuchar cambios en filtros
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
    ever(dateRange, (_) => _applyFilters());
    ever(minSize, (_) => _applyFilters());
    ever(maxSize, (_) => _applyFilters());
  }

  // Cargar documentos
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      final docs = await _documentRepository.getDocuments();
      documents.value = docs;
      totalDocuments.value = docs.length;
      _applyFilters();
    } catch (e) {
      _showErrorMessage('Error cargando documentos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Aplicar filtros
  void _applyFilters() {
    var filtered = documents.where((doc) {
      // Filtro de búsqueda
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!doc.name.toLowerCase().contains(query) &&
            !doc.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro de categoría
      if (selectedCategory.value != 'all' &&
          doc.category != selectedCategory.value) {
        return false;
      }

      // Filtro de rango de fechas
      if (dateRange.value != null) {
        final range = dateRange.value!;
        if (doc.createdAt.isBefore(range.start) ||
            doc.createdAt.isAfter(range.end)) {
          return false;
        }
      }

      // Filtro de tamaño
      if (doc.size < minSize.value || doc.size > maxSize.value) {
        return false;
      }

      return true;
    }).toList();

    // Aplicar ordenamiento
    _sortDocuments(filtered);
    filteredDocuments.value = filtered;
  }

  // Ordenar documentos
  void _sortDocuments(List<DocumentModel> docs) {
    switch (sortBy.value) {
      case SortBy.name:
        docs.sort((a, b) => sortAscending.value
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case SortBy.date:
        docs.sort((a, b) => sortAscending.value
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.size:
        docs.sort((a, b) => sortAscending.value
            ? a.size.compareTo(b.size)
            : b.size.compareTo(a.size));
        break;
      case SortBy.type:
        docs.sort((a, b) => sortAscending.value
            ? a.type.compareTo(b.type)
            : b.type.compareTo(a.type));
        break;
    }
  }

  // Subir archivos individuales
  Future<void> uploadFiles() async {
    try {
      final files = await _fileService.pickDocuments(multiple: true);
      if (files != null && files.isNotEmpty) {
        isUploading.value = true;

        for (final file in files) {
          await _uploadSingleFile(file);
        }

        await loadDocuments();
        _showSuccessMessage(
            '${files.length} archivo(s) subido(s) correctamente');
      }
    } catch (e) {
      _showErrorMessage('Error subiendo archivos: $e');
    } finally {
      isUploading.value = false;
    }
  }

  // Subir múltiples archivos
  Future<void> uploadMultipleFiles(List<PlatformFile> files) async {
    try {
      isUploading.value = true;

      // Validar archivos
      for (final file in files) {
        if (file.size > FileService.maxFileSize) {
          throw Exception('El archivo ${file.name} es demasiado grande');
        }
      }

      // Subir todos los archivos
      final results = await _documentRepository.uploadMultipleFiles(files);

      await loadDocuments();
      _showSuccessMessage(
          '${results.length} archivo(s) subido(s) correctamente');
    } catch (e) {
      _showErrorMessage('Error subiendo archivos: $e');
    } finally {
      isUploading.value = false;
    }
  }

  // Subir un solo archivo
  Future<void> _uploadSingleFile(PlatformFile file) async {
    await _documentRepository.uploadFile(file, {
      'category':
          selectedCategory.value != 'all' ? selectedCategory.value : 'general',
      'description': 'Documento subido desde la aplicación',
    });
  }

  // Eliminar documentos seleccionados
  Future<void> deleteSelectedDocuments() async {
    if (selectedDocuments.isEmpty) {
      _showWarningMessage('No hay documentos seleccionados');
      return;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${selectedDocuments.length} documento(s)?\n\nEsta acción no se puede deshacer.',
        ),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        isLoading.value = true;
        await _documentRepository
            .deleteMultipleDocuments(selectedDocuments.toList());
        await loadDocuments();
        clearSelection();
        _showSuccessMessage('Documentos eliminados correctamente');
      } catch (e) {
        _showErrorMessage('Error eliminando documentos: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Descargar documentos seleccionados
  Future<void> downloadSelectedDocuments() async {
    if (selectedDocuments.isEmpty) {
      _showWarningMessage('No hay documentos seleccionados');
      return;
    }

    try {
      _showInfoMessage(
          'Descargando ${selectedDocuments.length} documento(s)...');

      for (final docId in selectedDocuments) {
        final document = documents.firstWhere((doc) => doc.id == docId);
        await _documentRepository.downloadDocument(document);
      }

      _showSuccessMessage('Documentos descargados correctamente');
    } catch (e) {
      _showErrorMessage('Error descargando documentos: $e');
    }
  }

  // Toggle selección de documento
  void toggleSelection(String documentId) {
    if (selectedDocuments.contains(documentId)) {
      selectedDocuments.remove(documentId);
    } else {
      selectedDocuments.add(documentId);
    }
  }

  // Seleccionar todos los documentos
  void selectAll() {
    if (selectedDocuments.length == filteredDocuments.length) {
      clearSelection();
    } else {
      selectedDocuments.value = filteredDocuments.map((doc) => doc.id).toList();
    }
  }

  // Limpiar selección
  void clearSelection() {
    selectedDocuments.clear();
  }

  // Abrir documento
  void openDocument(DocumentModel document) {
    Get.toNamed('/document-viewer', arguments: document);
  }

  // Mostrar diálogo de búsqueda
  void showSearchDialog() {
    final controller = TextEditingController(text: searchQuery.value);

    Get.dialog(
      AlertDialog(
        title: const Text('Buscar documentos'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre o descripción...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) => searchQuery.value = value,
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchQuery.value = '';
              Get.back();
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  // Refrescar documentos
  Future<void> refreshDocuments() async {
    await loadDocuments();
    _showSuccessMessage('Documentos actualizados');
  }

  // Manejar acciones del menú
  void handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        setSortBy(SortBy.name);
        break;
      case 'sort_date':
        setSortBy(SortBy.date);
        break;
      case 'sort_size':
        setSortBy(SortBy.size);
        break;
      case 'view_grid':
        setViewMode(ViewMode.grid);
        break;
      case 'view_list':
        setViewMode(ViewMode.list);
        break;
    }
  }

  // Establecer modo de vista
  void setViewMode(ViewMode mode) {
    viewMode.value = mode;
  }

  // Establecer criterio de ordenamiento
  void setSortBy(SortBy criteria) {
    if (sortBy.value == criteria) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = criteria;
      sortAscending.value = false;
    }
    _applyFilters();
  }

  // Filtros
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void filterByDateRange(DateTimeRange? range) {
    dateRange.value = range;
  }

  void filterBySizeRange(double min, double max) {
    minSize.value = min;
    maxSize.value = max;
  }

  // Acciones rápidas
  void openFolder() {
    Get.toNamed('/folders');
  }

  void showRecentDocuments() {
    selectedCategory.value = 'all';
    sortBy.value = SortBy.date;
    sortAscending.value = false;
    searchQuery.value = '';
    _applyFilters();
  }

  void showFavoriteDocuments() {
    _showInfoMessage('Función en desarrollo');
  }

  void showTrash() {
    Get.toNamed('/trash');
  }

  // Mensajes
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

  void _showWarningMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  void _showInfoMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  void onClose() {
    clearSelection();
    super.onClose();
  }
}
