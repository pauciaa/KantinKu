import 'package:flutter/material.dart';

/// Baris ChoiceChip untuk memfilter menu berdasarkan kategori.
///
/// Widget ini tidak menyimpan state sendiri: kategori yang aktif dikirim dari
/// parent, dan pilihan baru dilaporkan lewat [onDipilih].
class FilterKategori extends StatelessWidget {
  final String kategoriTerpilih;
  final ValueChanged<String> onDipilih;

  const FilterKategori({
    super.key,
    required this.kategoriTerpilih,
    required this.onDipilih,
  });

  static const List<(String, IconData)> daftarKategori = [
    ('Semua', Icons.apps),
    ('Makanan', Icons.rice_bowl),
    ('Minuman', Icons.local_drink),
    ('Camilan', Icons.cookie),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final (nama, ikon) in daftarKategori)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(nama),
                avatar: kategoriTerpilih == nama ? null : Icon(ikon, size: 18),
                selected: kategoriTerpilih == nama,
                onSelected: (_) => onDipilih(nama),
              ),
            ),
        ],
      ),
    );
  }
}
