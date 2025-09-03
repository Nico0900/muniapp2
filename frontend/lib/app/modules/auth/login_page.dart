import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intranet_graneros/app/core/widgets/responsive_layout.dart';
import '../../core/theme/app_theme.dart';
import 'auth_controller.dart'; // importa tu ResponsiveUtils

class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: _buildLoginForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final formWidth = ResponsiveUtils.getValue<double>(
      context,
      mobile: double.infinity,
      tablet: 400.0,
      desktop: 500.0,
    );

    return Container(
      width: formWidth,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 40.h),
                _buildEmailField(),
                SizedBox(height: 20.h),
                _buildPasswordField(),
                SizedBox(height: 12.h),
                _buildForgotPasswordLink(),
                SizedBox(height: 32.h),
                _buildLoginButton(context),
                if (isDesktop) ...[
                  SizedBox(height: 24.h),
                  // _buildSystemInfo(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final logoSize = ResponsiveUtils.getValue<double>(context,
        mobile: 60, tablet: 80, desktop: 100);
    final iconSize = ResponsiveUtils.getValue<double>(context,
        mobile: 30, tablet: 40, desktop: 50);
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 24);
    final subtitleSize = ResponsiveUtils.getResponsiveFontSize(context, 14);

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child:
              Icon(Icons.account_balance, size: iconSize, color: Colors.white),
        ),
        SizedBox(height: 16.h),
        Text(
          'Intranet Municipal',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Acceso para Jefes de Departamento',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: subtitleSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Obx(() => TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            hintText: 'Ingresa tu correo institucional',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: controller.emailError.value.isEmpty
                ? null
                : controller.emailError.value,
          ),
          validator: controller.validateEmail,
          onChanged: (_) => controller.emailError.value = '',
        ));
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordHidden.value,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => controller.login(),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Ingresa tu contraseña',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(controller.isPasswordHidden.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: controller.togglePasswordVisibility,
            ),
            errorText: controller.passwordError.value.isEmpty
                ? null
                : controller.passwordError.value,
          ),
          validator: controller.validatePassword,
          onChanged: (_) => controller.passwordError.value = '',
        ));
  }

  Widget _buildForgotPasswordLink() {
    return Builder(
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: controller.forgotPassword,
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getValue<double>(context,
        mobile: 44, tablet: 48, desktop: 52);

    return Obx(() => SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }

  // Widget _buildSystemInfo() {
  //   return Container(
  //     padding: EdgeInsets.all(12.w),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(8.r),
  //       border: Border.all(color: Colors.grey[200]!),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.info_outline, size: 16.sp, color: AppTheme.textSecondary),
  //         SizedBox(width: 8.w),
  //         Expanded(
  //           child: Text(
  //             'Sistema de Gestión Documental v1.0.0',
  //             style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
