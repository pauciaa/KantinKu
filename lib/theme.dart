import 'package:flutter/material.dart';

/// Tema KantinKu (P06): warna dari seed oranye kantin, terang dan gelap.
///
/// Font Poppins disimpan sebagai file di assets/fonts/ dan didaftarkan di
/// pubspec.yaml, sehingga sudah termuat sebelum layar pertama tampil dan
/// tidak perlu internet. (Sebelumnya memakai google_fonts yang mengunduh
/// font saat aplikasi berjalan, sehingga teks ChoiceChip terpotong saat
/// aplikasi pertama kali dibuka.)
class AppTheme {
  static const Color primarySeed = Colors.deepOrange;
  static const String font = 'Poppins';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: font,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: font,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    ),
  );
}
