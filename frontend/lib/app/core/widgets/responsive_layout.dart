import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bp = ResponsiveBreakpoints.of(context);

    if (bp.smallerThan(TABLET)) {
      return mobile;
    } else if (bp.smallerThan(DESKTOP)) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }
}

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      ResponsiveBreakpoints.of(context).smallerThan(TABLET);

  static bool isTablet(BuildContext context) =>
      ResponsiveBreakpoints.of(context).between(TABLET, DESKTOP);

  static bool isDesktop(BuildContext context) =>
      ResponsiveBreakpoints.of(context).largerThan(TABLET);

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(getValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    ));
  }

  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    return getValue(
      context,
      mobile: baseFontSize,
      tablet: baseFontSize * 1.1,
      desktop: baseFontSize * 1.2,
    );
  }

  static int getGridColumns(BuildContext context) {
    return getValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
}
