import 'package:flutter/material.dart';

import 'model_menu.dart';
import 'kartu_menu.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // Indeks tab yang sedang dipilih
  int _indexTab = 0;

  // Data contoh menu
  
final List<Menu> _daftarMenu = [
  Menu(
    id: 'm1',
    nama: 'Nasi Ayam Geprek Sambal Korek',
    kantin: 'Kantin TULT',
    kategori: 'Makanan',
    harga: 15000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T08:00:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm2',
    nama: 'Mie Goreng Spesial Telur',
    kantin: 'Kantin TULT',
    kategori: 'Makanan',
    harga: 12000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T08:15:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm3',
    nama: 'Soto Ayam Lamongan',
    kantin: 'Kantin GKU',
    kategori: 'Makanan',
    harga: 14000,
    tersedia: false,
    diperbarui: DateTime.parse('2026-11-08T08:30:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm4',
    nama: 'Nasi Gila Kampus',
    kantin: 'Kantin GKU',
    kategori: 'Makanan',
    harga: 16000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T08:45:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm5',
    nama: 'Rice Bowl Chicken Katsu',
    kantin: 'Kantin Teknik',
    kategori: 'Makanan',
    harga: 18000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T09:00:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm6',
    nama: 'Es Teh Manis Jumbo',
    kantin: 'Kantin TULT',
    kategori: 'Minuman',
    harga: 5000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T09:10:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm7',
    nama: 'Es Kopi Susu Gula Aren',
    kantin: 'Kantin GKU',
    kategori: 'Minuman',
    harga: 12000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T09:20:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm8',
    nama: 'Jus Alpukat Cokelat',
    kantin: 'Kantin Teknik',
    kategori: 'Minuman',
    harga: 10000,
    tersedia: false,
    diperbarui: DateTime.parse('2026-11-08T09:30:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm9',
    nama: 'Es Jeruk Peras Segar',
    kantin: 'Kantin Asrama',
    kategori: 'Minuman',
    harga: 7000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T09:40:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm10',
    nama: 'Batagor Kuah Kacang',
    kantin: 'Kantin Teknik',
    kategori: 'Camilan',
    harga: 10000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T09:50:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm11',
    nama: 'Cireng Bumbu Rujak',
    kantin: 'Kantin Asrama',
    kategori: 'Camilan',
    harga: 8000,
    tersedia: true,
    diperbarui: DateTime.parse('2026-11-08T10:00:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
  Menu(
    id: 'm12',
    nama: 'Pisang Crispy Keju',
    kantin: 'Kantin Asrama',
    kategori: 'Camilan',
    harga: 9000,
    tersedia: false,
    diperbarui: DateTime.parse('2026-11-08T10:15:00.000'),
    gambar: 'assets/logo_kantin.png',
  ),
];


  // Data keranjang
  final Map<String, Menu> _itemKeranjang = {};

  final Map<String, int> _jumlahKeranjang = {};

  // Menambahkan menu ke keranjang
  void _tambahKeKeranjang(Menu menu) {
    setState(() {
      _itemKeranjang[menu.id] = menu;

      _jumlahKeranjang[menu.id] = (_jumlahKeranjang[menu.id] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menu.nama} masuk ke keranjang'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Mengubah jumlah menu di keranjang
  void _ubahJumlahKeranjang(String idMenu, int selisih) {
    setState(() {
      final jumlahSekarang = _jumlahKeranjang[idMenu] ?? 0;

      final jumlahBaru = jumlahSekarang + selisih;

      if (jumlahBaru <= 0) {
        _jumlahKeranjang.remove(idMenu);
        _itemKeranjang.remove(idMenu);
      } else {
        _jumlahKeranjang[idMenu] = jumlahBaru;
      }
    });
  }

  // Menghitung total harga
  int _hitungTotalHarga() {
    int total = 0;

    _jumlahKeranjang.forEach((id, jumlah) {
      final menu = _itemKeranjang[id];

      if (menu != null) {
        total += menu.harga * jumlah;
      }
    });

    return total;
  }

  // Menampilkan detail sementara
  // Nantinya akan diganti dengan HalamanDetail oleh P05
  void _tampilkanDetail(Menu menu) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(menu.nama),
          content: Text(
            'Kantin: ${menu.kantin}\n'
            'Kategori: ${menu.kategori}\n'
            'Harga: Rp ${menu.harga}\n'
            'Status: ${menu.tersedia ? "Tersedia" : "Habis"}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final skemaWarna = Theme.of(context).colorScheme;

    return Scaffold(
      // Header aplikasi
      appBar: AppBar(
        title: const Text('KantinKu - Pre-Order Kampus'),
        backgroundColor: skemaWarna.primaryContainer,
        foregroundColor: skemaWarna.onPrimaryContainer,
      ),

      // Mempertahankan state setiap tab
      body: IndexedStack(
        index: _indexTab,
        children: [
          _bangunTabMenu(),
          _bangunTabKeranjang(skemaWarna),
          _bangunTabProfil(skemaWarna),
        ],
      ),

      // Navigasi bawah
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexTab,

        onDestinationSelected: (indexBaru) {
          setState(() {
            _indexTab = indexBaru;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),

          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // TAB 1: MENU
  Widget _bangunTabMenu() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),

      itemCount: _daftarMenu.length,

      itemBuilder: (context, index) {
        final item = _daftarMenu[index];

        return KartuMenu(
          menu: item,

          onKetukDetail: () {
            _tampilkanDetail(item);
          },

          onTambahKeranjang: () {
            _tambahKeKeranjang(item);
          },
        );
      },
    );
  }

  // TAB 2: KERANJANG
  Widget _bangunTabKeranjang(ColorScheme skemaWarna) {
    final daftarId = _jumlahKeranjang.keys.toList();

    final totalHarga = _hitungTotalHarga();

    if (daftarId.isEmpty) {
      return const Center(child: Text('Keranjang pre-order masih kosong.'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: daftarId.length,

            itemBuilder: (context, index) {
              final id = daftarId[index];

              final menu = _itemKeranjang[id]!;

              final jumlah = _jumlahKeranjang[id]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(
                    menu.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    '${menu.kantin} • Rp ${menu.harga} '
                    'x $jumlah = Rp ${menu.harga * jumlah}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _ubahJumlahKeranjang(id, -1);
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),

                      Text('$jumlah'),

                      IconButton(
                        onPressed: () {
                          _ubahJumlahKeranjang(id, 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Total harga
        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: skemaWarna.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pre-Order:'),

                  Text(
                    'Rp $totalHarga',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: skemaWarna.primary,
                    ),
                  ),
                ],
              ),

              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _jumlahKeranjang.clear();
                    _itemKeranjang.clear();
                  });
                },

                icon: const Icon(Icons.check_circle_outline),

                label: const Text('Pesan Sekarang'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: PROFIL
  Widget _bangunTabProfil(ColorScheme skemaWarna) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        Card(
          color: skemaWarna.primaryContainer,

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.asset(
                    'assets/logo_kantin.png',
                    width: 60,
                    height: 60,

                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.storefront,
                        size: 50,
                        color: skemaWarna.onPrimaryContainer,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Kelompok 02 - KantinKu',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: skemaWarna.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Aplikasi Menu Kantin & Pre-Order '
                        'Jam Istirahat Telkom University',

                        style: TextStyle(color: skemaWarna.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Informasi Aplikasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Card(
          child: ListTile(
            leading: Icon(Icons.restaurant),

            title: Text('KantinKu'),

            subtitle: Text(
              'Aplikasi menu kantin dan pre-order '
              'Telkom University.',
            ),
          ),
        ),
      ],
    );
  }
}
