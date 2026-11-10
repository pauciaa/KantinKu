import 'package:flutter/material.dart';

/// Tampilan saat daftar kosong, lengkap dengan satu tombol aksi.
class TampilanKosong extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String pesan;
  final String labelTombol;
  final VoidCallback onTombol;

  const TampilanKosong({
    super.key,
    required this.ikon,
    required this.judul,
    required this.pesan,
    required this.labelTombol,
    required this.onTombol,
  });

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 64, color: skema.outline),
            const SizedBox(height: 16),
            Text(
              judul,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              pesan,
              style: TextStyle(color: skema.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onTombol,
              child: Text(labelTombol),
            ),
          ],
        ),
      ),
    );
  }
}
