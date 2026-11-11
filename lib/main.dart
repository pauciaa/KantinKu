import 'package:flutter/material.dart';

import 'theme.dart';
import 'layanan_menu.dart';
import 'halaman_utama.dart';

void main() {
  runApp(const KantinKuP04App());
}

class KantinKuP04App extends StatefulWidget {
  const KantinKuP04App({super.key, this.layananMenu});

  final LayananMenu? layananMenu;

  @override
  State<KantinKuP04App> createState() => _KantinKuP04AppState();
}

class _KantinKuP04AppState extends State<KantinKuP04App> {
  /// Awalnya mengikuti pengaturan HP, lalu bisa diganti lewat tombol di AppBar.
  ThemeMode _modeTema = ThemeMode.system;

  /// Berpindah ke kebalikan dari tema yang sedang tampil.
  void _gantiTema(Brightness sekarang) {
    setState(() {
      _modeTema =
          sekarang == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KantinKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Tema Mode Terang (P06)
      darkTheme: AppTheme.darkTheme, // Tema Mode Gelap (P06)
      themeMode: _modeTema,
      home: HalamanUtama(
        layananMenu: widget.layananMenu,
        onGantiTema: _gantiTema,
      ),
    );
  }
}
