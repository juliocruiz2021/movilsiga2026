import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.scaffold,
    required this.surface,
    required this.surfaceSoft,
    required this.textStrong,
    required this.textMuted,
    required this.infoContainer,
    required this.infoText,
    required this.dangerContainer,
    required this.danger,
    required this.success,
    required this.shadow,
    required this.overlayStrong,
    required this.overlaySoft,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.orbA,
    required this.orbB,
    required this.orbC,
  });

  final Color primary;
  final Color secondary;
  final Color onPrimary;
  final Color scaffold;
  final Color surface;
  final Color surfaceSoft;
  final Color textStrong;
  final Color textMuted;
  final Color infoContainer;
  final Color infoText;
  final Color dangerContainer;
  final Color danger;
  final Color success;
  final Color shadow;
  final Color overlayStrong;
  final Color overlaySoft;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color orbA;
  final Color orbB;
  final Color orbC;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? onPrimary,
    Color? scaffold,
    Color? surface,
    Color? surfaceSoft,
    Color? textStrong,
    Color? textMuted,
    Color? infoContainer,
    Color? infoText,
    Color? dangerContainer,
    Color? danger,
    Color? success,
    Color? shadow,
    Color? overlayStrong,
    Color? overlaySoft,
    Color? gradientStart,
    Color? gradientMid,
    Color? gradientEnd,
    Color? orbA,
    Color? orbB,
    Color? orbC,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      onPrimary: onPrimary ?? this.onPrimary,
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      textStrong: textStrong ?? this.textStrong,
      textMuted: textMuted ?? this.textMuted,
      infoContainer: infoContainer ?? this.infoContainer,
      infoText: infoText ?? this.infoText,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      shadow: shadow ?? this.shadow,
      overlayStrong: overlayStrong ?? this.overlayStrong,
      overlaySoft: overlaySoft ?? this.overlaySoft,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      orbA: orbA ?? this.orbA,
      orbB: orbB ?? this.orbB,
      orbC: orbC ?? this.orbC,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      scaffold: Color.lerp(scaffold, other.scaffold, t) ?? scaffold,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t) ?? surfaceSoft,
      textStrong: Color.lerp(textStrong, other.textStrong, t) ?? textStrong,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      infoContainer:
          Color.lerp(infoContainer, other.infoContainer, t) ?? infoContainer,
      infoText: Color.lerp(infoText, other.infoText, t) ?? infoText,
      dangerContainer:
          Color.lerp(dangerContainer, other.dangerContainer, t) ??
          dangerContainer,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      success: Color.lerp(success, other.success, t) ?? success,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
      overlayStrong:
          Color.lerp(overlayStrong, other.overlayStrong, t) ?? overlayStrong,
      overlaySoft: Color.lerp(overlaySoft, other.overlaySoft, t) ?? overlaySoft,
      gradientStart:
          Color.lerp(gradientStart, other.gradientStart, t) ?? gradientStart,
      gradientMid: Color.lerp(gradientMid, other.gradientMid, t) ?? gradientMid,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t) ?? gradientEnd,
      orbA: Color.lerp(orbA, other.orbA, t) ?? orbA,
      orbB: Color.lerp(orbB, other.orbB, t) ?? orbB,
      orbC: Color.lerp(orbC, other.orbC, t) ?? orbC,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static const AppPalette lightPalette = AppPalette(
    primary: Color(0xFF6B7482),
    secondary: Color(0xFFB9C1CB),
    onPrimary: Colors.white,
    scaffold: Color(0xFFF3F5F8),
    surface: Colors.white,
    surfaceSoft: Color(0xFFEDF1F5),
    textStrong: Color(0xFF2F3640),
    textMuted: Color(0xFF697382),
    infoContainer: Color(0xFFE8ECF1),
    infoText: Color(0xFF556170),
    dangerContainer: Color(0xFFFFE9EC),
    danger: Color(0xFFB00020),
    success: Color(0xFF3FA97D),
    shadow: Color(0xFF000000),
    overlayStrong: Color(0xFF000000),
    overlaySoft: Color(0xFF000000),
    gradientStart: Color(0xFFF4F6F8),
    gradientMid: Color(0xFFE9EDF2),
    gradientEnd: Color(0xFFF8FAFC),
    orbA: Color(0xFFD5DBE3),
    orbB: Color(0xFFC7CED8),
    orbC: Color(0xFFE1E5EB),
  );

  static const AppPalette systemPalette = AppPalette(
    primary: Color(0xFF08A6F6),
    secondary: Color(0xFF3A85FF),
    onPrimary: Colors.white,
    scaffold: Color(0xFFE8F4FF),
    surface: Colors.white,
    surfaceSoft: Color(0xFFF1F8FF),
    textStrong: Color(0xFF0A2442),
    textMuted: Color(0xFF426586),
    infoContainer: Color(0xFFD7EEFF),
    infoText: Color(0xFF0A5D92),
    dangerContainer: Color(0xFFFFE9EC),
    danger: Color(0xFFB00020),
    success: Color(0xFF2BC89A),
    shadow: Color(0xFF000000),
    overlayStrong: Color(0xFF000000),
    overlaySoft: Color(0xFF000000),
    gradientStart: Color(0xFF1F2ED0),
    gradientMid: Color(0xFF0AA6F1),
    gradientEnd: Color(0xFF0A67E7),
    orbA: Color(0xFF0B47C4),
    orbB: Color(0xFF17C2F7),
    orbC: Color(0xFFCC5DFF),
  );

  static const AppPalette skyPalette = AppPalette(
    primary: Color(0xFF1597FF),
    secondary: Color(0xFF7FD3FF),
    onPrimary: Colors.white,
    scaffold: Color(0xFFF4FAFF),
    surface: Colors.white,
    surfaceSoft: Color(0xFFF6FAFF),
    textStrong: Color(0xFF0A2B3C),
    textMuted: Color(0xFF4C6F8A),
    infoContainer: Color(0xFFE7F5FF),
    infoText: Color(0xFF0A5B8B),
    dangerContainer: Color(0xFFFFE9EC),
    danger: Color(0xFFB00020),
    success: Color(0xFF35C69A),
    shadow: Color(0xFF000000),
    overlayStrong: Color(0xFF000000),
    overlaySoft: Color(0xFF000000),
    gradientStart: Color(0xFFE8F6FF),
    gradientMid: Color(0xFFBCEBFF),
    gradientEnd: Color(0xFFF5FBFF),
    orbA: Color(0xFF8AD8FF),
    orbB: Color(0xFF4FB6FF),
    orbC: Color(0xFFBFE9FF),
  );

  static const AppPalette darkPalette = AppPalette(
    primary: Color(0xFF4AA8FF),
    secondary: Color(0xFF76CCFF),
    onPrimary: Color(0xFF04101A),
    scaffold: Color(0xFF07111B),
    surface: Color(0xFF122334),
    surfaceSoft: Color(0xFF1A2E42),
    textStrong: Color(0xFFE6F3FF),
    textMuted: Color(0xFF9AB6CF),
    infoContainer: Color(0xFF15354C),
    infoText: Color(0xFFAEDCFF),
    dangerContainer: Color(0xFF512431),
    danger: Color(0xFFFF7A93),
    success: Color(0xFF49D3A5),
    shadow: Color(0xFF000000),
    overlayStrong: Color(0xFF000000),
    overlaySoft: Color(0xFF000000),
    gradientStart: Color(0xFF0A1725),
    gradientMid: Color(0xFF0D2133),
    gradientEnd: Color(0xFF08121D),
    orbA: Color(0xFF1D3E5B),
    orbB: Color(0xFF204A71),
    orbC: Color(0xFF17334C),
  );

  static ThemeData light() =>
      _buildFromPalette(lightPalette, brightness: Brightness.light);

  static ThemeData systemTheme() =>
      _buildFromPalette(systemPalette, brightness: Brightness.light);

  static ThemeData sky() =>
      _buildFromPalette(skyPalette, brightness: Brightness.light);

  static ThemeData dark() =>
      _buildFromPalette(darkPalette, brightness: Brightness.dark);

  static ThemeData _buildFromPalette(
    AppPalette palette, {
    required Brightness brightness,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme)
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          titleSmall: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(bodyColor: palette.textStrong, displayColor: palette.textStrong);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: palette.primary,
        secondary: palette.secondary,
        onPrimary: palette.onPrimary,
        surface: palette.surface,
        onSurface: palette.textStrong,
        error: palette.danger,
      ),
      brightness: brightness,
      scaffoldBackgroundColor: palette.scaffold,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface.withValues(alpha: 0.95),
        foregroundColor: palette.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.textStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.94),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.94),
        indicatorColor: palette.primary.withValues(alpha: 0.16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textStrong,
        contentTextStyle: TextStyle(color: palette.surface),
      ),
      cardTheme: CardThemeData(
        color: palette.surface.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette {
    final theme = Theme.of(this);
    final ext = theme.extension<AppPalette>();
    if (ext != null) return ext;
    return theme.brightness == Brightness.dark
        ? AppTheme.darkPalette
        : AppTheme.lightPalette;
  }
}
