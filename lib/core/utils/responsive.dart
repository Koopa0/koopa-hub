import 'package:flutter/material.dart';

/// 響應式斷點定義
///
/// 參考 Material Design 3 響應式佈局指南
class Breakpoints {
  /// 手機（Portrait）
  static const double mobile = 600;

  /// 平板（Portrait）/ 手機（Landscape）
  static const double tablet = 900;

  /// 桌面 / 平板（Landscape）
  static const double desktop = 1200;

  /// 大螢幕桌面
  static const double wide = 1600;
}

/// 裝置類型
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
}

/// 響應式輔助工具
class Responsive {
  const Responsive._();

  /// 取得當前裝置類型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.wide) {
      return DeviceType.wide;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// 是否為手機
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 是否為平板
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 是否為桌面
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.wide;
  }

  /// 根據螢幕寬度取得值
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// 響應式建構器
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
    super.key,
  });

  /// 手機佈局
  final Widget mobile;

  /// 平板佈局（可選，預設使用 mobile）
  final Widget? tablet;

  /// 桌面佈局（可選，預設使用 tablet 或 mobile）
  final Widget? desktop;

  /// 大螢幕佈局（可選，預設使用 desktop, tablet 或 mobile）
  final Widget? wide;

  @override
  Widget build(BuildContext context) {
    return Responsive.valueWhen(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      wide: wide,
    );
  }
}

/// 響應式間距
class ResponsiveSpacing {
  const ResponsiveSpacing._();

  /// 取得響應式間距
  static double spacing(BuildContext context) {
    return Responsive.valueWhen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  /// 取得響應式邊距
  static EdgeInsets padding(BuildContext context) {
    final spacing = ResponsiveSpacing.spacing(context);
    return EdgeInsets.all(spacing);
  }

  /// 取得響應式水平邊距
  static EdgeInsets horizontalPadding(BuildContext context) {
    final spacing = ResponsiveSpacing.spacing(context);
    return EdgeInsets.symmetric(horizontal: spacing);
  }

  /// 取得響應式垂直邊距
  static EdgeInsets verticalPadding(BuildContext context) {
    final spacing = ResponsiveSpacing.spacing(context);
    return EdgeInsets.symmetric(vertical: spacing);
  }
}
