import 'package:flutter/material.dart';

import 'theme.dart';
import 'layanan_menu.dart';
import 'halaman_utama.dart';

void main() {
  runApp(const KantinKuP04App());
}

class KantinKuP04App extends StatelessWidget {
  const KantinKuP04App({super.key, this.layananMenu});

  final LayananMenu? layananMenu;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KantinKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,      // Tema Mode Terang (P06)
      darkTheme: AppTheme.darkTheme,    // Tema Mode Gelap (P06)
      themeMode: ThemeMode.system,     // Otomatis menyesuaikan mode perangkat
      home: HalamanUtama(layananMenu: layananMenu),
    );
  }
}