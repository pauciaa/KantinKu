import 'package:flutter/material.dart';

import 'model_menu.dart';

class KartuMenu extends StatelessWidget {
  final Menu menu;
  final VoidCallback onKetukDetail;
  final VoidCallback onTambahKeranjang;

  const KartuMenu({
    super.key,
    required this.menu,
    required this.onKetukDetail,
    required this.onTambahKeranjang,
  });

  @override
  Widget build(BuildContext context) {
    final skemaWarna = Theme.of(context).colorScheme;

    return Opacity(
      opacity: menu.tersedia ? 1.0 : 0.55,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: skemaWarna.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onKetukDetail,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Gambar dan label Habis
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animasi Hero
                    Hero(
                      tag: 'gambar_${menu.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 72,
                          height: 72,
                          color: skemaWarna.primaryContainer,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            menu.gambar,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fastfood,
                                size: 36,
                                color: skemaWarna.onPrimaryContainer,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Label Habis
                    if (!menu.tersedia)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: skemaWarna.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Habis',
                          style: TextStyle(
                            color: skemaWarna.onError,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Informasi makanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.nama,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: skemaWarna.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${menu.kantin} • ${menu.kategori}',
                        style: TextStyle(
                          fontSize: 13,
                          color: skemaWarna.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Rp ${menu.harga}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: skemaWarna.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol tambah ke keranjang
                FilledButton.tonalIcon(
                  onPressed: menu.tersedia ? onTambahKeranjang : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Pesan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
