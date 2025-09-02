import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intranet_graneros/app/core/widgets/responsive_layout.dart';

import '../../core/theme/app_theme.dart';
import 'documents_controller.dart';
import 'widgets/document_card.dart';
import 'widgets/upload_area.dart';
import 'widgets/document_filter.dart';

class DocumentsPage extends GetView<DocumentsController> {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  // ---------------- MOBILE ----------------
  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        SliverToBoxAdapter(child: _buildUploadArea()),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        SliverToBoxAdapter(child: _buildFilters()),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        _buildDocumentsList(
            isGridView: controller.viewMode.value == ViewMode.grid),
      ],
    );
  }

  // ---------------- TABLET ----------------
  Widget _buildTabletLayout() {
    return Row(
      children: [
        Container(
          width: 280.w,
          padding: EdgeInsets.all(16.w),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadArea(),
              SizedBox(height: 24.h),
              _buildFilters(),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              _buildDocumentsList(
                  isGridView: controller.viewMode.value == ViewMode.grid),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- DESKTOP ----------------
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 320.w,
          padding: EdgeInsets.all(24.w),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadArea(),
              SizedBox(height: 32.h),
              _buildFilters(),
              SizedBox(height: 32.h),
              _buildQuickActions(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildDesktopHeader(),
              Expanded(
                  child: _buildDocumentsList(
                      isGridView: controller.viewMode.value == ViewMode.grid)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- APPBAR ----------------
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      elevation: 1,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Documentos',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Obx(() => Text(
                '${controller.totalDocuments.value} documentos',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              )),
        ],
      ),
      actions: [
        Obx(() => controller.selectedDocuments.isNotEmpty
            ? _buildSelectionActions()
            : _buildNormalActions()),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Documentos',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() => Text(
                      '${controller.totalDocuments.value} documentos • ${controller.selectedDocuments.length} seleccionados',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    )),
              ],
            ),
          ),
          Obx(() => controller.selectedDocuments.isNotEmpty
              ? _buildBulkActions()
              : _buildNormalActions()),
        ],
      ),
    );
  }

  // ---------------- LISTA DOCUMENTOS ----------------
  Widget _buildDocumentsList({required bool isGridView}) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: const CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (controller.documents.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64.sp,
                    color: AppTheme.textDisabled,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No hay documentos',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sube tu primer documento para comenzar',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.all(16.w),
        sliver: isGridView
            ? SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Get.width > 1000 ? 4 : 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final document = controller.documents[index];
                    return DocumentCard(
                      document: document,
                      isSelected:
                          controller.selectedDocuments.contains(document.id),
                      onTap: () => controller.openDocument(document),
                      onLongPress: () =>
                          controller.toggleSelection(document.id),
                      onSelectionChanged: (selected) =>
                          controller.toggleSelection(document.id),
                    );
                  },
                  childCount: controller.documents.length,
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final document = controller.documents[index];
                    return DocumentCard(
                      document: document,
                      isSelected:
                          controller.selectedDocuments.contains(document.id),
                      isListView: true,
                      onTap: () => controller.openDocument(document),
                      onLongPress: () =>
                          controller.toggleSelection(document.id),
                      onSelectionChanged: (selected) =>
                          controller.toggleSelection(document.id),
                    );
                  },
                  childCount: controller.documents.length,
                ),
              ),
      );
    });
  }

  // ---------------- OTROS WIDGETS ----------------
  Widget _buildUploadArea() => UploadArea(
        onFilesSelected: controller.uploadFiles,
        onMultipleFilesSelected: controller.uploadMultipleFiles,
      );

  Widget _buildFilters() => DocumentFilters(
        onCategoryChanged: controller.filterByCategory,
        onDateRangeChanged: controller.filterByDateRange,
        onSizeRangeChanged: controller.filterBySizeRange,
      );

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        _buildQuickActionButton(
          icon: Icons.folder_open,
          label: 'Abrir carpeta',
          onTap: controller.openFolder,
        ),
        _buildQuickActionButton(
          icon: Icons.history,
          label: 'Documentos recientes',
          onTap: controller.showRecentDocuments,
        ),
        _buildQuickActionButton(
          icon: Icons.star_outline,
          label: 'Documentos favoritos',
          onTap: controller.showFavoriteDocuments,
        ),
        _buildQuickActionButton(
          icon: Icons.delete_outline,
          label: 'Papelera',
          onTap: controller.showTrash,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppTheme.textSecondary),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ACCIONES ----------------
  Widget _buildSelectionActions() {
    return Row(
      children: [
        Text(
          '${controller.selectedDocuments.length}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
          onPressed: controller.deleteSelectedDocuments,
          tooltip: 'Eliminar seleccionados',
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: controller.downloadSelectedDocuments,
          tooltip: 'Descargar seleccionados',
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.clearSelection,
          tooltip: 'Limpiar selección',
        ),
      ],
    );
  }

  Widget _buildBulkActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: controller.selectAll,
          icon: const Icon(Icons.select_all),
          label: const Text('Seleccionar Todo'),
        ),
        SizedBox(width: 12.w),
        OutlinedButton.icon(
          onPressed: controller.downloadSelectedDocuments,
          icon: const Icon(Icons.download),
          label: const Text('Descargar'),
        ),
        SizedBox(width: 12.w),
        ElevatedButton.icon(
          onPressed: controller.deleteSelectedDocuments,
          icon: const Icon(Icons.delete),
          label: const Text('Eliminar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: controller.showSearchDialog,
          tooltip: 'Buscar documentos',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.refreshDocuments,
          tooltip: 'Actualizar',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: controller.handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort_name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 20),
                  SizedBox(width: 12),
                  Text('Ordenar por nombre'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 12),
                  Text('Ordenar por fecha'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_grid',
              child: Row(
                children: [
                  Icon(Icons.grid_view, size: 20),
                  SizedBox(width: 12),
                  Text('Vista de cuadrícula'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_list',
              child: Row(
                children: [
                  Icon(Icons.list, size: 20),
                  SizedBox(width: 12),
                  Text('Vista de lista'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
