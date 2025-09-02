import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intranet_graneros/app/modules/documents/documents_pages.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_layout.dart';
import 'home_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../profile/profile_page.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildMobileAppBar(),
      body: Obx(() => _getPage(controller.selectedIndex.value)),
      bottomNavigationBar: _buildBottomNavigation(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        _buildSideNavigation(isExpanded: false),
        Expanded(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Obx(() => _getPage(controller.selectedIndex.value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSideNavigation(isExpanded: true),
        Expanded(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Obx(() => _getPage(controller.selectedIndex.value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Obx(() => Text(
            _getPageTitle(controller.selectedIndex.value),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          )),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: controller.showNotifications,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: controller.showMenu,
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Text(
                  _getPageTitle(controller.selectedIndex.value),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                )),
          ),
          _buildUserAvatar(),
          SizedBox(width: 16.w),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: controller.showNotifications,
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: controller.showSettings,
            tooltip: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation({required bool isExpanded}) {
    return Container(
      width: isExpanded ? 280.w : 72.w,
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          _buildSideHeader(isExpanded),
          Expanded(
            child: _buildNavigationItems(isExpanded),
          ),
          _buildSideFooter(isExpanded),
        ],
      ),
    );
  }

  Widget _buildSideHeader(bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance,
              color: AppTheme.primaryColor,
              size: 24.sp,
            ),
          ),
          if (isExpanded) ...[
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intranet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Municipal',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems(bool isExpanded) {
    return Obx(() => ListView(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          children: controller.navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = controller.selectedIndex.value == index;

            return _buildNavigationItem(
              item: item,
              isSelected: isSelected,
              isExpanded: isExpanded,
              onTap: () => controller.changeTab(index),
            );
          }).toList(),
        ));
  }

  Widget _buildNavigationItem({
    required NavigationItem item,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16.w : 0,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                if (!isExpanded) const Spacer(),
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 24.sp,
                ),
                if (isExpanded) ...[
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
                if (!isExpanded) const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideFooter(bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 8.h),
          InkWell(
            onTap: controller.logout,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              child: Row(
                children: [
                  if (!isExpanded) const Spacer(),
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  if (isExpanded) ...[
                    SizedBox(width: 12.w),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (!isExpanded) const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: controller.navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.title,
                  ))
              .toList(),
        ));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: _buildDrawerItems(),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(),
          SizedBox(height: 16.h),
          Obx(() => Text(
                controller.currentUser.value?.fullName ?? 'Usuario',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
          Obx(() => Text(
                controller.currentUser.value?.departmentName ?? 'Departamento',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDrawerItems() {
    return Obx(() => ListView(
          padding: EdgeInsets.zero,
          children: [
            ...controller.navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: controller.selectedIndex.value == index,
                onTap: () {
                  controller.changeTab(index);
                  Get.back(); // Cerrar drawer
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: controller.showSettings,
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda'),
              onTap: controller.showHelp,
            ),
          ],
        ));
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.red)),
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Obx(() => CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.white,
          child: controller.currentUser.value?.avatar != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.network(
                    controller.currentUser.value!.avatar!,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  controller.currentUser.value?.initials ?? 'U',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
        ));
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const DocumentsPage();
      case 2:
        return const ProfilePage();
      default:
        return const DashboardPage();
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Documentos';
      case 2:
        return 'Perfil';
      default:
        return 'Dashboard';
    }
  }
}
