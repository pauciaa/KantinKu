import 'package:flutter/material.dart';
import 'model_menu.dart';
import 'halaman_menu.dart';
import 'model_keranjang.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Menu> _daftarMenu = [
    Menu(
      id: 1,
      nama: 'Nasi Ayam Goreng',
      kantin: 'Kantin A',
      kategori: 'Makanan',
      harga: 15000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 2,
      nama: 'Nasi Goreng',
      kantin: 'Kantin A',
      kategori: 'Makanan',
      harga: 13000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 3,
      nama: 'Mie Ayam',
      kantin: 'Kantin B',
      kategori: 'Makanan',
      harga: 12000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 4,
      nama: 'Soto Ayam',
      kantin: 'Kantin B',
      kategori: 'Makanan',
      harga: 14000,
      tersedia: false,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 5,
      nama: 'Nasi Pecel',
      kantin: 'Kantin C',
      kategori: 'Makanan',
      harga: 10000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 6,
      nama: 'Es Teh',
      kantin: 'Kantin A',
      kategori: 'Minuman',
      harga: 4000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 7,
      nama: 'Es Jeruk',
      kantin: 'Kantin A',
      kategori: 'Minuman',
      harga: 5000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 8,
      nama: 'Air Mineral',
      kantin: 'Kantin B',
      kategori: 'Minuman',
      harga: 3000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 9,
      nama: 'Jus Alpukat',
      kantin: 'Kantin C',
      kategori: 'Minuman',
      harga: 8000,
      tersedia: false,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 10,
      nama: 'Pisang Goreng',
      kantin: 'Kantin A',
      kategori: 'Camilan',
      harga: 6000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 11,
      nama: 'Risol',
      kantin: 'Kantin B',
      kategori: 'Camilan',
      harga: 3000,
      tersedia: true,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
    Menu(
      id: 12,
      nama: 'Tahu Isi',
      kantin: 'Kantin C',
      kategori: 'Camilan',
      harga: 4000,
      tersedia: false,
      diperbarui: DateTime(2026, 10, 1),
      gambar: '',
    ),
  ];

  final List<ItemPesanan> _keranjang = [];

  int get _jumlahItemKeranjang =>
      _keranjang.fold(0, (total, item) => total + item.jumlah);

  void _ubahHalaman(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _tampilkanSnackBar(String pesan, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
          action: aksi,
        ),
      );
  }

  void _tambahKeKeranjang(Menu menu) {
    setState(() {
      final index = _keranjang.indexWhere((item) => item.menu.id == menu.id);
      if (index == -1) {
        _keranjang.add(ItemPesanan(menu: menu));
      } else {
        _keranjang[index].jumlah++;
      }
    });

    _tampilkanSnackBar(
      '${menu.nama} ditambahkan ke keranjang',
      aksi: SnackBarAction(
        label: 'Lihat',
        onPressed: () => _ubahHalaman(1),
      ),
    );
  }

  Widget _halamanKeranjang() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Halaman Keranjang',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            'Fitur keranjang akan diintegrasikan kemudian.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _halamanProfil() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Halaman Profil',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KantinKu'),
        centerTitle: true,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HalamanMenu(
            daftarMenu: _daftarMenu,
            onTambah: _tambahKeKeranjang,
          ),
          _halamanKeranjang(),
          _halamanProfil(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _ubahHalaman,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _jumlahItemKeranjang > 0,
              label: Text('$_jumlahItemKeranjang'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
