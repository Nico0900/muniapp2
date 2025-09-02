import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intranet_graneros/app/core/theme/app_theme.dart';
import 'package:intranet_graneros/app/data/models/document_model.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final bool isListView;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(bool)? onSelectionChanged;

  const DocumentCard({
    Key? key,
    required this.document,
    this.isSelected = false,
    this.isListView = false,
    this.onTap,
    this.onLongPress,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isListView ? _buildListTile() : _buildGridCard();
  }

  Widget _buildGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFileIcon()),
                    if (onSelectionChanged != null)
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value != null) onSelectionChanged!(value);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const Spacer(),
                _buildFileName(),
                SizedBox(height: 4.h),
                _buildFileInfo(),
                SizedBox(height: 8.h),
                _buildFileDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                _buildFileIcon(),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFileName(),
                      SizedBox(height: 4.h),
                      _buildFileInfo(),
                      SizedBox(height: 4.h),
                      _buildFileDetails(),
                    ],
                  ),
                ),
                if (onSelectionChanged != null) ...[
                  SizedBox(width: 8.w),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value != null) onSelectionChanged!(value);
                    },
                  ),
                ],
                SizedBox(width: 8.w),
                _buildMoreOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    return Container(
      width: isListView ? 48.w : 64.w,
      height: isListView ? 48.h : 64.h,
      decoration: BoxDecoration(
        color: _getFileColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        _getFileIcon(),
        size: isListView ? 24.sp : 32.sp,
        color: _getFileColor(),
      ),
    );
  }

  Widget _buildFileName() {
    return Text(
      document.name,
      style: TextStyle(
        fontSize: isListView ? 14.sp : 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      maxLines: isListView ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFileInfo() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            document.extension.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          document.sizeFormatted,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 12.sp,
              color: AppTheme.textDisabled,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                document.uploadedByName,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textDisabled,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 12.sp,
              color: AppTheme.textDisabled,
            ),
            SizedBox(width: 4.w),
            Text(
              _formatDate(document.createdAt),
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textDisabled,
              ),
            ),
          ],
        ),
        if (!isListView && document.downloadCount > 0) ...[
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(
                Icons.download,
                size: 12.sp,
                color: AppTheme.textDisabled,
              ),
              SizedBox(width: 4.w),
              Text(
                '${document.downloadCount} descargas',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMoreOptions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20.sp,
        color: AppTheme.textSecondary,
      ),
      onSelected: _handleMenuOption,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, size: 16),
              SizedBox(width: 8),
              Text('Descargar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 16),
              SizedBox(width: 8),
              Text('Compartir'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Renombrar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuOption(String option) {
    switch (option) {
      case 'download':
        break;
      case 'share':
        break;
      case 'rename':
        break;
      case 'delete':
        break;
    }
  }

  IconData _getFileIcon() {
    switch (document.extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (document.extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'txt':
        return Colors.grey;
      case 'zip':
      case 'rar':
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getCategoryColor() {
    switch (document.category.toLowerCase()) {
      case 'financial':
        return Colors.green;
      case 'legal':
        return Colors.blue;
      case 'technical':
        return Colors.orange;
      case 'administrative':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}
