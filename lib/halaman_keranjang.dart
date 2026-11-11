import 'package:flutter/material.dart';

import 'format_harga.dart';
import 'item_keranjang.dart';
import 'model_keranjang.dart';
import 'tampilan_kosong.dart';

/// Tab Keranjang: daftar pesanan, total harga, dan tombol pesan.
class HalamanKeranjang extends StatelessWidget {
  final List<ItemPesanan> keranjang;
  final ValueChanged<ItemPesanan> onTambah;
  final ValueChanged<ItemPesanan> onKurang;
  final ValueChanged<ItemPesanan> onHapus;
  final VoidCallback onPesan;
  final VoidCallback onLihatMenu;

  const HalamanKeranjang({
    super.key,
    required this.keranjang,
    required this.onTambah,
    required this.onKurang,
    required this.onHapus,
    required this.onPesan,
    required this.onLihatMenu,
  });

  int get _total => keranjang.fold(0, (total, item) => total + item.subtotal);

  @override
  Widget build(BuildContext context) {
    if (keranjang.isEmpty) {
      return TampilanKosong(
        ikon: Icons.shopping_cart_outlined,
        judul: 'Keranjang masih kosong',
        pesan: 'Pilih menu favoritmu untuk diambil saat jam istirahat.',
        labelTombol: 'Lihat Menu',
        onTombol: onLihatMenu,
      );
    }

    final skema = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: keranjang.length,
            itemBuilder: (context, index) {
              final item = keranjang[index];
              return ItemKeranjang(
                key: ValueKey(item.menu.id),
                item: item,
                onTambah: () => onTambah(item),
                onKurang: () => onKurang(item),
                onHapus: () => onHapus(item),
              );
            },
          ),
        ),
        Material(
          color: skema.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(color: skema.onSurfaceVariant),
                      ),
                      Text(
                        formatRupiah(_total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: skema.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onPesan,
                  icon: const Icon(Icons.check),
                  label: const Text('Pesan Sekarang'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
