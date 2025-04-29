import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color pk = Color(0xff4f46e5);

abstract final class AppTheme {
  static ThemeData light = ThemeData.light(useMaterial3: false).copyWith(
    primaryColor: pk,
    colorScheme: ColorScheme.fromSeed(seedColor: pk, primary: pk),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 24),
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      floatingLabelStyle: TextStyle(),
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    ),
    textTheme: GoogleFonts.openSansTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      bodySmall: TextStyle(fontSize: 12, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black45),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    chipTheme: ChipThemeData(
      selectedColor: pk.withValues(alpha: 0.4),
      showCheckmark: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
    brightness: Brightness.light,
  );
  static ThemeData dark = ThemeData.dark();
}
