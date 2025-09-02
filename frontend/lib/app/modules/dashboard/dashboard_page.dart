import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_layout.dart';
import 'dashboard_controller.dart';
import 'widgets/stats_card.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/quick_actions_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({Key? key}) : super(key: key);

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

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 16.h),
            _buildStatsGrid(),
            SizedBox(height: 16.h),
            _buildQuickActions(),
            SizedBox(height: 16.h),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 24.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildStatsGrid(),
                      SizedBox(height: 24.h),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 1,
                  child: _buildQuickActions(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 32.h),
            _buildStatsGrid(),
            SizedBox(height: 32.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildRecentActivity(),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  flex: 1,
                  child: _buildQuickActions(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getValue(
        Get.context!,
        mobile: 16.w,
        tablet: 24.w,
        desktop: 32.w,
      )),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.getGreeting(),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getValue(
                              Get.context!,
                              mobile: 16.sp,
                              tablet: 18.sp,
                              desktop: 20.sp,
                            ),
                            color: Colors.white.withOpacity(0.9),
                          ),
                        )),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          controller.currentUser.value?.fullName ?? 'Usuario',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getValue(
                              Get.context!,
                              mobile: 24.sp,
                              tablet: 28.sp,
                              desktop: 32.sp,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                    SizedBox(height: 8.h),
                    Obx(() => Text(
                          controller.currentUser.value?.departmentName ??
                              'Departamento',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )),
                  ],
                ),
              ),
              Icon(
                Icons.wb_sunny_outlined,
                size: 48.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: ResponsiveUtils.getValue(
            Get.context!,
            mobile: 2,
            tablet: 4,
            desktop: 4,
          ),
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: ResponsiveUtils.getValue(
            Get.context!,
            mobile: 1.2,
            tablet: 1.5,
            desktop: 1.5,
          ),
          children: [
            StatsCard(
              title: 'Documentos',
              value: controller.totalDocuments.value.toString(),
              subtitle: 'Total subidos',
              icon: Icons.description_outlined,
              color: Colors.blue,
              trend: controller.documentsTrend.value,
            ),
            StatsCard(
              title: 'Este mes',
              value: controller.documentsThisMonth.value.toString(),
              subtitle: 'Nuevos documentos',
              icon: Icons.add_circle_outline,
              color: Colors.green,
              trend: controller.monthlyTrend.value,
            ),
            StatsCard(
              title: 'Descargas',
              value: controller.totalDownloads.value.toString(),
              subtitle: 'Total descargas',
              icon: Icons.download_outlined,
              color: Colors.orange,
              trend: controller.downloadsTrend.value,
            ),
            StatsCard(
              title: 'Almacenamiento',
              value: controller.storageUsed.value,
              subtitle: 'Espacio usado',
              icon: Icons.storage_outlined,
              color: Colors.purple,
              trend: controller.storageTrend.value,
            ),
          ],
        ));
  }

  Widget _buildQuickActions() {
    return QuickActionsCard(
      onUploadDocument: controller.uploadDocument,
      onViewDocuments: controller.viewDocuments,
      onOpenProfile: controller.openProfile,
      onViewReports: controller.viewReports,
    );
  }

  Widget _buildRecentActivity() {
    return Obx(() => RecentActivityCard(
          activities: controller.recentActivities.value,
          isLoading: controller.isLoadingActivity.value,
          onRefresh: controller.refreshActivity,
        ));
  }
}
