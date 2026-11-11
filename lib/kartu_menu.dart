import 'package:flutter/material.dart';
import 'format_harga.dart';
import 'model_menu.dart';

class KartuMenu extends StatelessWidget {
  final Menu menu;

  /// Dipanggil saat tombol + ditekan. Jika null, tombol tidak ditampilkan.
  final VoidCallback? onTambah;

  /// Dipanggil saat kartu diketuk. Null di halaman detail, agar kartu di
  /// sana tidak membuka halaman detail lagi.
  final VoidCallback? onTap;

  const KartuMenu({
    super.key,
    required this.menu,
    this.onTambah,
    this.onTap,
  });

  Widget _gambarCadangan(ColorScheme skema) {
    return Container(
      color: skema.primaryContainer,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: skema.onPrimaryContainer,
        ),
      ),
    );
  }

  /// Gambar menu: kosong -> ikon, "assets/..." -> aset lokal, selain itu URL.
  Widget _gambarMenu(ColorScheme skema) {
    if (menu.gambar.isEmpty) return _gambarCadangan(skema);

    if (menu.gambar.startsWith('assets/')) {
      return Image.asset(
        menu.gambar,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _gambarCadangan(skema),
      );
    }

    return Image.network(
      menu.gambar,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _gambarCadangan(skema),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Opacity(
              opacity: menu.tersedia ? 1.0 : 0.45,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animasi Hero: gambar "terbang" dari kartu ke halaman detail.
                    Hero(
                      tag: 'menu-${menu.id}',
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _gambarMenu(skema),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            menu.kantin,
                            style: TextStyle(
                              color: skema.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            menu.kategori,
                            style: TextStyle(
                              color: skema.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatRupiah(menu.harga),
                                  style: TextStyle(
                                    color: skema.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (onTambah != null)
                                IconButton.filledTonal(
                                  tooltip: menu.tersedia
                                      ? 'Tambah ke keranjang'
                                      : 'Menu habis',
                                  icon: const Icon(Icons.add),
                                  onPressed: menu.tersedia ? onTambah : null,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!menu.tersedia)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: skema.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Habis',
                    style: TextStyle(
                      color: skema.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}