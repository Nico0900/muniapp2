import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_theme.dart';

class UploadArea extends StatefulWidget {
  final VoidCallback? onFilesSelected;
  final Function(List<PlatformFile>)? onMultipleFilesSelected;

  const UploadArea({
    Key? key,
    this.onFilesSelected,
    this.onMultipleFilesSelected,
  }) : super(key: key);

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  bool _isDragOver = false;
  late DropzoneViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subir Documentos',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildUploadArea(),
          SizedBox(height: 16.h),
          _buildUploadOptions(),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return kIsWeb ? _buildWebUploadArea() : _buildMobileUploadArea();
  }

  Widget _buildWebUploadArea() {
    return Stack(
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? AppTheme.primaryColor : Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: _isDragOver
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey[50],
          ),
        ),
        DropzoneView(
          onCreated: (controller) => _controller = controller,
          onLoaded: () => print('Dropzone loaded'),
          onHover: () => setState(() => _isDragOver = true),
          onLeave: () => setState(() => _isDragOver = false),
          onDrop: (event) async {
            final name = await _controller.getFilename(event);
            final size = await _controller.getFileSize(event);
            final bytes = await _controller.getFileData(event);

            if (size > 50 * 1024 * 1024) {
              _showError('El archivo $name excede 50MB');
              return;
            }

            widget.onMultipleFilesSelected
                ?.call([PlatformFile(name: name, size: size, bytes: bytes)]);
            setState(() => _isDragOver = false);
          },
          operation: DragOperation.copy,
          cursor: CursorType.pointer,
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48.sp,
                  color: _isDragOver ? AppTheme.primaryColor : Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Arrastra archivos aquí o haz clic para seleccionar',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: _isDragOver
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tipos soportados: PDF, DOC, XLS, PPT, TXT, IMG\nTamaño máximo: 50MB por archivo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMobileUploadArea() {
    return InkWell(
      onTap: _pickFiles,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[50],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text('Toca para seleccionar archivos',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.file_upload),
            label: const Text('Seleccionar archivos'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickMultipleFiles,
            icon: const Icon(Icons.folder_open),
            label: const Text('Múltiples archivos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'jpg',
          'jpeg',
          'png'
        ],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result?.files.isEmpty ?? true) return;

      final file = result!.files.first;
      if (file.size > 50 * 1024 * 1024) {
        _showError('El archivo ${file.name} excede 50MB');
        return;
      }

      widget.onFilesSelected?.call();
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showError('Error seleccionando archivo');
    }
  }

  Future<void> _pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'jpg',
          'jpeg',
          'png'
        ],
        allowMultiple: true,
        withData: kIsWeb,
      );

      if (result?.files.isEmpty ?? true) return;

      for (final file in result!.files) {
        if (file.size > 50 * 1024 * 1024) {
          _showError('El archivo ${file.name} excede 50MB');
          return;
        }
      }

      widget.onMultipleFilesSelected?.call(result.files);
    } catch (e) {
      debugPrint('Error picking files: $e');
      _showError('Error seleccionando archivos');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
