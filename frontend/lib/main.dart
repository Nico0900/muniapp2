import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientaciones permitidas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configurar la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar GetStorage
  await GetStorage.init();

  // Inicializar dependencias
  DependencyInjection.init();

  // Configurar Google Fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 como base
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Intranet Municipal',
          debugShowCheckedModeBanner: false,

          // Configuración de temas
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Configuración de rutas
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.routes,

          // Configuración de transiciones
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),

          // Configuración de localización
          locale: const Locale('es', 'CL'),
          fallbackLocale: const Locale('es', 'CL'),

          // ✅ Configuración responsive (API nueva)
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              child: ClampingScrollWrapper.builder(context, child!),
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1200, name: DESKTOP),
                Breakpoint(start: 1201, end: 2460, name: '4K'),
              ],
            );
          },

          // Configuraciones adicionales
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const NotFoundPage(),
          ),

          // Configuración de logs
          enableLog: true,
          logWriterCallback: (text, {bool isError = false}) {
            if (isError) {
              print('🔥 ERROR: $text');
            } else {
              print('📱 GetX: $text');
            }
          },
        );
      },
    );
  }
}

// Página de error 404
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16.h),
            Text(
              '404 - Página no encontrada',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'La página que buscas no existe',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
