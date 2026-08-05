import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Los nombres de estos tokens describen su ROL, no su color, para que la
  // paleta pueda reusarse con otra identidad de marca cambiando solo los hex.
  // No introducir nombres cromaticos (gold, navy, silver...).

  // --- Superficies: solo fondos, gradientes y glows. ---
  // Nunca usar como color de texto o de icono. Luminancia creciente:
  // darker < dark < surface < accent.
  static const Color darker = Color(0xFF08090B);
  static const Color dark = Color(0xFF101822);
  static const Color surface = Color(0xFF1B2A42);
  static const Color accent = Color(0xFF2C4B78);

  // --- Acento de marca: unico color saturado de la interfaz. ---
  static const Color primary = Color(0xFFC9A24D);
  static const Color primaryHover = Color(0xFFE4C982);
  static const Color onPrimary = Color(0xFF0A0F16);

  // --- Estructura y texto: solo primer plano. ---
  static const Color secondary = Color(0xFFAEB6BF);
  static const Color textPrimary = Color(0xFFF2F4F6);
  static const Color textSecondary = Color(0xFF9AA5B1);

  // Variantes traslucidas centralizadas: los widgets no deben llamar a
  // withOpacity() sobre un token directamente.
  static Color get cardBorder => secondary.withValues(alpha: 0.35);
  static Color get glow => accent.withValues(alpha: 0.28);
  static Color get glowSoft => primary.withValues(alpha: 0.10);

  // Scrim: capa que se interpone entre contenido fotografico y texto para
  // garantizar legibilidad. Se usa como gradiente vertical de scrimDense
  // (arriba, donde vive el texto) a scrimClear (abajo, donde vive el sujeto
  // de la foto). Su opacidad se calibra contra la zona MAS CLARA de la
  // imagen bajo la banda de texto, no contra su luminancia promedio: el
  // contrato de contraste de abajo esta definido frente a superficies
  // planas y no aplica a un bitmap.
  static Color get scrimDense => darker.withValues(alpha: 0.88);
  static Color get scrimClear => darker.withValues(alpha: 0.0);

  // Contrato de contraste (WCAG 2.1). Al cambiar cualquier valor de arriba,
  // reverificar estos pares:
  //
  //   primary       vs darker / dark / surface   >= 4.5:1   (es texto e icono)
  //   onPrimary     vs primary                   >= 4.5:1   (texto del boton)
  //   textPrimary   vs darker / dark / surface / accent >= 4.5:1
  //   textSecondary vs darker / dark / surface   >= 4.5:1
  //   secondary     vs surface                   >= 3:1     (bordes = UI)
  //
  // accent solo aparece como extremo de gradiente o glow; ningun texto de
  // cuerpo se apoya sobre el en estado solido.

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: onPrimary,
        onSecondary: darker,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darker,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 1.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
