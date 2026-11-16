import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Palette "Cinema": nero pieno + accento ambra.
abstract final class AppColors {
  static const background = Color(0xFF0E0E10);
  static const accent = Color(0xFFF5A524);

  /// Card: bianco al 6% sopra il nero, effetto "vetro" leggero.
  static const card = Color(0x0FFFFFFF);
  static const navBar = Color(0xFF16161A);
  static const sheet = Color(0xFF1A1A1E);
  static const raised = Color(0xFF242428);

  static const textPrimary = Color(0xFFF2F2F2);
  static const textSecondary = Color(0xFFCFCFCF);
  static const textMuted = Color(0xFF8A8A8F);
}

/// Tema unico (l'app è sempre scura).
///
/// Nota: come scoperto in Fresher, ColorScheme.fromSeed "normalizza" il
/// colore primario: per avere esattamente l'ambra lo forziamo con copyWith.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.accent,
    onPrimary: Colors.black,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerHighest: AppColors.raised,
  );

  Color selectedOrMuted(Set<WidgetState> states) =>
      states.contains(WidgetState.selected)
          ? AppColors.accent
          : AppColors.textMuted;

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      // Icone della status bar (ora, batteria) chiare su sfondo scuro.
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBar,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.accent.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: selectedOrMuted(states))),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selectedOrMuted(states),
          )),
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.accent,
      textColor: Colors.black,
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.accent),
    dividerTheme: const DividerThemeData(color: Color(0xFF222226)),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.raised,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
    ),
    bottomSheetTheme:
        const BottomSheetThemeData(backgroundColor: AppColors.sheet),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.sheet),
    popupMenuTheme: const PopupMenuThemeData(color: AppColors.raised),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: AppColors.accent,
      collapsedIconColor: AppColors.textMuted,
      // Niente linee sopra/sotto quando si apre.
      shape: Border(),
      collapsedShape: Border(),
    ),
  );
}
