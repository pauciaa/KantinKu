import 'package:flutter/material.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        useMaterial3: true,
      ),
      home: HalamanUtama(layananMenu: layananMenu),
    );
  }
}