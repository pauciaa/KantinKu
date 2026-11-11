import 'package:flutter/material.dart';

import 'layanan_menu.dart';
import 'model_kantin.dart';

/// Tab Profil: logo aplikasi (aset lokal) dan daftar kantin dari
/// endpoint khas GET /kantin.
class HalamanProfil extends StatefulWidget {
  final LayananMenu layananMenu;

  /// Naik setiap kali tab Profil dibuka, agar daftar kantin dimuat ulang.
  final int muatUlangKe;

  const HalamanProfil({
    super.key,
    required this.layananMenu,
    this.muatUlangKe = 0,
  });

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  late Future<List<Kantin>> _futureKantin;

  @override
  void initState() {
    super.initState();
    _futureKantin = widget.layananMenu.ambilDaftarKantin();
  }

  @override
  void didUpdateWidget(HalamanProfil lama) {
    super.didUpdateWidget(lama);
    if (widget.muatUlangKe != lama.muatUlangKe) {
      _futureKantin = widget.layananMenu.ambilDaftarKantin();
    }
  }

  Future<void> _muatUlang() async {
    final future = widget.layananMenu.ambilDaftarKantin();
    setState(() {
      _futureKantin = future;
    });
    try {
      await future;
    } on LayananMenuException {
      // Pesan error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final teks = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/logo.png',
                width: 96,
                height: 96,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('KantinKu', style: teks.headlineSmall, textAlign: TextAlign.center),
          Text(
            'Pesan menu kantin kampus, ambil saat jam istirahat.',
            style: teks.bodyMedium?.copyWith(color: skema.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text('Daftar Kantin', style: teks.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Kantin>>(
            future: _futureKantin,
            builder: (context, snapshot) {
              // Saat dimuat ulang, data lama tetap tampil (tidak berkedip).
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.cloud_off_outlined, color: skema.error),
                    title: const Text('Daftar kantin gagal dimuat'),
                    subtitle: Text('${snapshot.error}'),
                    trailing: IconButton(
                      tooltip: 'Coba lagi',
                      icon: const Icon(Icons.refresh),
                      onPressed: _muatUlang,
                    ),
                  ),
                );
              }
              final daftar = snapshot.data ?? [];
              return Card(
                child: Column(
                  children: [
                    for (final kantin in daftar)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: skema.primaryContainer,
                          foregroundColor: skema.onPrimaryContainer,
                          child: const Icon(Icons.storefront_outlined),
                        ),
                        title: Text(kantin.nama),
                        trailing: Text('${kantin.jumlahMenu} menu'),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
