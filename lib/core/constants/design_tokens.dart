import 'package:flutter/material.dart';

/// Design tokens for consistent spacing, sizing, and styling
///
/// Following Material Design 3 principles and Flutter best practices
/// https://m3.material.io/foundations/layout/applying-layout/spacing
class DesignTokens {
  DesignTokens._(); // Private constructor to prevent instantiation

  // ============================================================================
  // Spacing System (8dp grid)
  // ============================================================================
  /// Based on Material Design 3's 8dp grid system
  /// All spacing should be multiples of 4 for consistency

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Common padding presets
  static const EdgeInsets paddingAll4 = EdgeInsets.all(space4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(space12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(space24);

  static const EdgeInsets paddingH8V4 = EdgeInsets.symmetric(
    horizontal: space8,
    vertical: space4,
  );
  static const EdgeInsets paddingH12V6 = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space6,
  );
  static const EdgeInsets paddingH12V8 = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space8,
  );
  static const EdgeInsets paddingH12V12 = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space12,
  );
  static const EdgeInsets paddingH16V12 = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );
  static const EdgeInsets paddingH20V12 = EdgeInsets.symmetric(
    horizontal: space20,
    vertical: space12,
  );
  static const EdgeInsets paddingH8V2 = EdgeInsets.symmetric(
    horizontal: space8,
    vertical: space2,
  );

  static const double space2 = 2.0;
  static const double space6 = 6.0;
  static const double space10 = 10.0;

  // ============================================================================
  // Border Radius
  // ============================================================================
  /// Material Design 3 corner radius system

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0; // Fully rounded

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  // ============================================================================
  // Icon Sizes
  // ============================================================================

  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 18.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 24.0;
  static const double iconSizeXl = 32.0;
  static const double iconSize2xl = 48.0;
  static const double iconSize3xl = 64.0;

  // ============================================================================
  // Avatar/Circle Sizes
  // ============================================================================

  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 36.0;
  static const double avatarSizeLg = 48.0;

  // ============================================================================
  // Touch Targets
  // ============================================================================
  /// Minimum touch target size as per Material Design guidelines
  /// https://m3.material.io/foundations/layout/applying-layout/touch-targets

  static const double minTouchTarget = 48.0;
  static const Size minTouchTargetSize = Size(minTouchTarget, minTouchTarget);

  // ============================================================================
  // Animation Durations
  // ============================================================================
  /// Standard animation durations following Material Design motion guidelines
  /// https://m3.material.io/styles/motion/easing-and-duration/tokens-specs

  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);
  static const Duration durationSlower = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 1000);

  // ============================================================================
  // Elevation
  // ============================================================================
  /// Material Design 3 elevation system
  /// https://m3.material.io/styles/elevation/tokens

  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation5 = 5.0;

  // ============================================================================
  // Border Width
  // ============================================================================

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 4.0;

  // ============================================================================
  // Content Width
  // ============================================================================
  /// Maximum width for readable content

  static const double maxContentWidth = 600.0;
  static const double maxDialogWidth = 560.0;
  static const double maxFormWidth = 480.0;

  // ============================================================================
  // Opacity
  // ============================================================================

  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // ============================================================================
  // Loader/Progress Indicator Sizes
  // ============================================================================

  static const double loaderSizeSm = 12.0;
  static const double loaderSizeMd = 20.0;
  static const double loaderSizeLg = 32.0;
  static const double loaderStrokeWidthSm = 2.0;
  static const double loaderStrokeWidthMd = 3.0;
  static const double loaderStrokeWidthLg = 4.0;
}
