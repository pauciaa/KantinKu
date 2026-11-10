import 'package:flutter/material.dart';

import 'filter_kategori.dart';
import 'kartu_menu.dart';
import 'model_menu.dart';
import 'tampilan_kosong.dart';

/// Tab Menu: pencarian, filter kategori, dan daftar menu.
class HalamanMenu extends StatefulWidget {
  final List<Menu> daftarMenu;
  final ValueChanged<Menu> onTambah;

  const HalamanMenu({
    super.key,
    required this.daftarMenu,
    required this.onTambah,
  });

  @override
  State<HalamanMenu> createState() => _HalamanMenuState();
}

class _HalamanMenuState extends State<HalamanMenu> {
  final TextEditingController _cariController = TextEditingController();
  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    // Setiap ketikan memicu build ulang agar daftar langsung terfilter.
    _cariController.addListener(_saatTeksBerubah);
  }

  @override
  void dispose() {
    _cariController.removeListener(_saatTeksBerubah);
    _cariController.dispose();
    super.dispose();
  }

  void _saatTeksBerubah() {
    setState(() {});
  }

  void _pilihKategori(String kategori) {
    setState(() {
      _kategoriTerpilih = kategori;
    });
  }

  void _resetFilter() {
    _cariController.clear();
    setState(() {
      _kategoriTerpilih = 'Semua';
    });
  }

  List<Menu> get _menuTerfilter {
    final kataKunci = _cariController.text.trim().toLowerCase();

    return widget.daftarMenu.where((menu) {
      final cocokKategori =
          _kategoriTerpilih == 'Semua' || menu.kategori == _kategoriTerpilih;
      final cocokKataKunci = kataKunci.isEmpty ||
          menu.nama.toLowerCase().contains(kataKunci) ||
          menu.kantin.toLowerCase().contains(kataKunci);
      return cocokKategori && cocokKataKunci;
    }).toList();
  }

  Widget _kolomCari() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: _cariController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari menu atau kantin…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _cariController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close),
                  onPressed: _cariController.clear,
                ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _menuTerfilter;

    return Column(
      children: [
        _kolomCari(),
        FilterKategori(
          kategoriTerpilih: _kategoriTerpilih,
          onDipilih: _pilihKategori,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: hasil.isEmpty
              ? TampilanKosong(
                  ikon: Icons.search_off,
                  judul: 'Menu tidak ditemukan',
                  pesan: 'Coba kata kunci atau kategori lain.',
                  labelTombol: 'Reset filter',
                  onTombol: _resetFilter,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: hasil.length,
                  itemBuilder: (context, index) {
                    final menu = hasil[index];
                    return KartuMenu(
                      menu: menu,
                      onTambah: () => widget.onTambah(menu),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
