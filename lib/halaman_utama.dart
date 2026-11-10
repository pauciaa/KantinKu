import 'package:flutter/material.dart';

import 'layanan_menu.dart';
import 'model_menu.dart';
import 'form_usulan.dart';
import 'format_harga.dart';
import 'halaman_keranjang.dart';
import 'halaman_menu.dart';
import 'model_keranjang.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key, this.layananMenu});

  final LayananMenu? layananMenu;

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;
  late final LayananMenu _layananMenu = widget.layananMenu ?? LayananMenu();
  late Future<List<Menu>> _futureMenu;

  final List<ItemPesanan> _keranjang = [];

  @override
  void initState() {
    super.initState();
    _muatMenu();
  }

  @override
  void dispose() {
    _layananMenu.dispose();
    super.dispose();
  }

  void _muatMenu() {
    setState(() {
      _futureMenu = _layananMenu.ambilMenu();
    });
  }

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
          persist: false,
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

  void _tambahJumlah(ItemPesanan item) {
    setState(() {
      item.jumlah++;
    });
  }

  void _kurangiJumlah(ItemPesanan item) {
    setState(() {
      if (item.jumlah > 1) item.jumlah--;
    });
  }

  void _hapusDariKeranjang(ItemPesanan item) {
    final posisi = _keranjang.indexOf(item);
    setState(() {
      _keranjang.removeAt(posisi);
    });

    _tampilkanSnackBar(
      '${item.menu.nama} dihapus dari keranjang',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () => _kembalikanKeKeranjang(item, posisi),
      ),
    );
  }

  void _kembalikanKeKeranjang(ItemPesanan item, int posisi) {
    setState(() {
      final index =
          _keranjang.indexWhere((lain) => lain.menu.id == item.menu.id);
      if (index != -1) {
        _keranjang[index].jumlah += item.jumlah;
      } else {
        _keranjang.insert(posisi.clamp(0, _keranjang.length), item);
      }
    });
  }

  Future<void> _bukaFormUsulan() async {
    final usulan = await showModalBottomSheet<Menu>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const FormUsulan(),
    );

    if (usulan == null || !mounted) return;

    _tampilkanSnackBar(
      'Usulan "${usulan.nama}" untuk ${usulan.kantin} terkirim. Terima kasih!',
    );
  }

  void _pesanSekarang() {
    final total =
        _keranjang.fold(0, (total, item) => total + item.subtotal);
    setState(() {
      _keranjang.clear();
    });

    _tampilkanSnackBar(
      'Pesanan dibuat (${formatRupiah(total)}). Ambil saat jam istirahat!',
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
          _kontenMenuDenganFutureBuilder(),
          HalamanKeranjang(
            keranjang: _keranjang,
            onTambah: _tambahJumlah,
            onKurang: _kurangiJumlah,
            onHapus: _hapusDariKeranjang,
            onPesan: _pesanSekarang,
            onLihatMenu: () => _ubahHalaman(0),
          ),
          _halamanProfil(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _bukaFormUsulan,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Usulkan Menu'),
            )
          : null,
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

  /// [P07] Menangani 3 state menggunakan FutureBuilder: memuat, gagal (dengan tombol Coba lagi), dan berhasil.
  Widget _kontenMenuDenganFutureBuilder() {
    return FutureBuilder<List<Menu>>(
      future: _futureMenu,
      builder: (context, snapshot) {
        // State 1: Memuat (Loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Mengambil menu dari server...'),
              ],
            ),
          );
        }

        // State 2: Gagal (Error)
        if (snapshot.hasError) {
          final pesanError = snapshot.error is LayananMenuException
              ? (snapshot.error as LayananMenuException).pesan
              : snapshot.error.toString();

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Menu gagal dimuat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(pesanError, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _muatMenu,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // State 3: Berhasil (Success)
        final daftarMenu = snapshot.data ?? [];
        return HalamanMenu(
          daftarMenu: daftarMenu,
          onTambah: _tambahKeKeranjang,
        );
      },
    );
  }
}