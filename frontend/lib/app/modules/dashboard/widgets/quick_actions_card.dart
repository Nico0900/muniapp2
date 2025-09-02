import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onUploadDocument;
  final VoidCallback? onViewDocuments;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onViewReports;

  const QuickActionsCard({
    Key? key,
    this.onUploadDocument,
    this.onViewDocuments,
    this.onOpenProfile,
    this.onViewReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          _buildQuickAction(
            icon: Icons.upload_file,
            title: 'Subir Documento',
            subtitle: 'Agregar nuevo archivo',
            color: AppTheme.primaryColor,
            onTap: onUploadDocument,
          ),
          SizedBox(height: 16.h),
          _buildQuickAction(
            icon: Icons.folder_open,
            title: 'Ver Documentos',
            subtitle: 'Explorar archivos',
            color: Colors.blue,
            onTap: onViewDocuments,
          ),
          SizedBox(height: 16.h),
          _buildQuickAction(
            icon: Icons.person,
            title: 'Mi Perfil',
            subtitle: 'Configurar cuenta',
            color: Colors.orange,
            onTap: onOpenProfile,
          ),
          SizedBox(height: 16.h),
          _buildQuickAction(
            icon: Icons.bar_chart,
            title: 'Reportes',
            subtitle: 'Ver estadísticas',
            color: Colors.purple,
            onTap: onViewReports,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
