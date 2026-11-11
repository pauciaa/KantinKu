import 'package:flutter/material.dart';

import 'format_harga.dart';
import 'model_keranjang.dart';

/// Satu baris di keranjang dengan tombol kurang/tambah jumlah.
///
/// Saat jumlah tinggal 1, tombol kurang berubah menjadi tombol hapus.
class ItemKeranjang extends StatelessWidget {
  final ItemPesanan item;
  final VoidCallback onTambah;
  final VoidCallback onKurang;
  final VoidCallback onHapus;

  const ItemKeranjang({
    super.key,
    required this.item,
    required this.onTambah,
    required this.onKurang,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final sisaSatu = item.jumlah == 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: skema.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant, color: skema.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menu.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.menu.kantin,
                    style: TextStyle(
                      color: skema.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(item.subtotal),
                    style: TextStyle(
                      color: skema.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: sisaSatu ? 'Hapus' : 'Kurangi',
              icon: Icon(sisaSatu ? Icons.delete_outline : Icons.remove),
              color: sisaSatu ? skema.error : null,
              onPressed: sisaSatu ? onHapus : onKurang,
            ),
            SizedBox(
              width: 24,
              child: Text(
                '${item.jumlah}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Tambah',
              icon: const Icon(Icons.add),
              onPressed: onTambah,
            ),
          ],
        ),
      ),
    );
  }
}
