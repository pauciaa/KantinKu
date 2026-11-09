import 'package:flutter/material.dart';
import 'model_menu.dart';

class KartuMenu extends StatelessWidget {
  final Menu menu;

  const KartuMenu({
    super.key,
    required this.menu,
  });

  String _formatHarga(int harga) {
    final hargaString = harga.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < hargaString.length; i++) {
      hasil.write(hargaString[i]);

      final sisa = hargaString.length - i - 1;

      if (sisa > 0 && sisa % 3 == 0) {
        hasil.write('.');
      }
    }

    return 'Rp${hasil.toString()}';
  }

  Widget _gambarMenu() {
    if (menu.gambar.isEmpty) {
      return Container(
        color: Colors.orange.shade50,
        child: const Center(
          child: Icon(
            Icons.restaurant,
            size: 48,
            color: Colors.deepOrange,
          ),
        ),
      );
    }

    return Image.network(
      menu.gambar,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.orange.shade50,
          child: const Center(
            child: Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.deepOrange,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Stack(
        children: [
          Opacity(
            opacity: menu.tersedia ? 1.0 : 0.45,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _gambarMenu(),
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
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          menu.kategori,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _formatHarga(menu.harga),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Habis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
