import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemaMoodi {
  // Cores Extraídas do Tailwind
  static const Color primario = Color(0xFFa43b31);
  static const Color primarioContainer = Color(0xFFff7f70);
  static const Color noPrimarioContainer = Color(0xFF731712);
  
  static const Color secundario = Color(0xFF006b5c);
  static const Color secundarioContainer = Color(0xFF8ff5df);
  
  static const Color fundo = Color(0xFFfdf9f5);
  static const Color noFundo = Color(0xFF1c1c19);
  
  static const Color superficie = Color(0xFFfdf9f5);
  static const Color superficieVariante = Color(0xFFe5e2de);
  static const Color superficieBaixa = Color(0xFFf7f3ef);
  static const Color superficieMaisBaixa = Color(0xFFffffff);
  
  static const Color contorno = Color(0xFF8a716e);
  static const Color contornoVariante = Color(0xFFdec0bc);

  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primario,
        primaryContainer: primarioContainer,
        onPrimaryContainer: noPrimarioContainer,
        secondary: secundario,
        secondaryContainer: secundarioContainer,
        surface: superficie,
        onSurface: noFundo,
        outline: contorno,
      ),
      scaffoldBackgroundColor: fundo,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.02, color: noFundo),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.01, color: noFundo),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w400, color: noFundo),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: noFundo),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02, color: noFundo),
      ),
    );
  }
}
