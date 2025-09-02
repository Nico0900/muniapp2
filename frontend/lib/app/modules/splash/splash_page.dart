import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            SizedBox(height: 40.h),
            _buildTitle(),
            SizedBox(height: 20.h),
            _buildSubtitle(),
            SizedBox(height: 60.h),
            _buildLoadingIndicator(),
            const Spacer(),
            _buildVersion(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance,
        size: 60.sp,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Intranet Municipal',
      style: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Sistema de Gestión Documental',
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() => Column(
          children: [
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              controller.loadingMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ));
  }

  Widget _buildVersion() {
    return Text(
      'v1.0.0',
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}
