import 'package:flutter/material.dart';

import 'kartu_menu.dart';
import 'model_menu.dart';

/// Halaman detail yang menerima [Menu] lewat konstruktor.
class HalamanDetailMenu extends StatelessWidget {
  final Menu menu;

  const HalamanDetailMenu({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final tanggal = menu.diperbarui;
    return Scaffold(
      appBar: AppBar(title: Text(menu.nama)),
      body: ListView(
        children: [
          KartuMenu(menu: menu),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Diperbarui'),
            subtitle: Text('${tanggal.day}/${tanggal.month}/${tanggal.year}'),
          ),
        ],
      ),
    );
  }
}
