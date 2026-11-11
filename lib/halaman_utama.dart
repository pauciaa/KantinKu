import 'package:flutter/material.dart';

import 'layanan_menu.dart';
import 'model_menu.dart';
import 'form_usulan.dart';
import 'format_harga.dart';
import 'halaman_keranjang.dart';
import 'halaman_menu.dart';
import 'halaman_profil.dart';
import 'model_keranjang.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key, this.layananMenu, this.onGantiTema});

  final LayananMenu? layananMenu;

  /// Dipanggil tombol mode gelap/terang di AppBar dengan tema yang sedang
  /// tampil. Jika null, tombol tidak ditampilkan.
  final ValueChanged<Brightness>? onGantiTema;

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;
  late final LayananMenu _layananMenu = widget.layananMenu ?? LayananMenu();
  late Future<List<Menu>> _futureMenu;

  /// Menu dari form tambah. Disimpan di State agar langsung muncul di daftar,
  /// walaupun pengiriman ke server gagal.
  final List<Menu> _menuUsulan = [];

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

  /// Memuat ulang dari awal (dipakai saat pertama dibuka dan tombol Coba lagi).
  void _muatMenu() {
    setState(() {
      _futureMenu = _layananMenu.ambilMenu();
    });
  }

  /// Pull-to-refresh: daftar lama tetap tampil selama data baru diambil.
  Future<void> _segarkanMenu() async {
    try {
      final data = await _layananMenu.ambilMenu();
      if (!mounted) return;
      setState(() {
        _futureMenu = Future.value(data);
      });
    } on LayananMenuException catch (e) {
      if (!mounted) return;
      _tampilkanSnackBar(e.pesan);
    }
  }

  /// Menu usulan ditaruh paling atas, tanpa dobel jika server sudah
  /// mengembalikannya.
  List<Menu> _gabungkanDenganUsulan(List<Menu> dariServer) {
    final idServer = dariServer.map((menu) => menu.id).toSet();
    return [
      ..._menuUsulan.where((menu) => !idServer.contains(menu.id)),
      ...dariServer,
    ];
  }

  int get _jumlahItemKeranjang =>
      _keranjang.fold(0, (total, item) => total + item.jumlah);

  /// Tombol di AppBar untuk berpindah mode terang/gelap.
  Widget _tombolTema(BuildContext context) {
    final gelap = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: gelap ? 'Mode terang' : 'Mode gelap',
      icon: Icon(gelap ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => widget.onGantiTema!(Theme.of(context).brightness),
    );
  }

  /// Naik setiap kali tab Profil dibuka, agar daftar kantin selalu terbaru.
  int _muatUlangProfil = 0;

  void _ubahHalaman(int index) {
    setState(() {
      if (index == 2 && _selectedIndex != 2) _muatUlangProfil++;
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

  /// Membuka halaman form tambah. Data dikembalikan lewat
  /// Navigator.pop(context, usulan), lalu langsung dimasukkan ke daftar
  /// dan dikirim ke server dengan POST.
  Future<void> _bukaFormUsulan() async {
    final usulan = await Navigator.push<Menu>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          resizeToAvoidBottomInset: false,
          body: const FormUsulan(),
        ),
      ),
    );

    if (usulan == null || !mounted) return;

    setState(() {
      _menuUsulan.insert(0, usulan);
    });
    _tampilkanSnackBar('Mengirim usulan "${usulan.nama}" ke server...');

    try {
      final tersimpan = await _layananMenu.kirimUsulan(usulan);
      if (!mounted) return;
      setState(() {
        final index = _menuUsulan.indexOf(usulan);
        if (index != -1) _menuUsulan[index] = tersimpan;
      });
      _tampilkanSnackBar(
        'Usulan "${tersimpan.nama}" untuk ${tersimpan.kantin} tersimpan di server.',
      );
    } on LayananMenuException catch (e) {
      if (!mounted) return;
      _tampilkanSnackBar('Usulan hanya tersimpan di aplikasi. ${e.pesan}');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KantinKu'),
        centerTitle: true,
        actions: [
          if (widget.onGantiTema != null) _tombolTema(context),
        ],
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
          HalamanProfil(
            layananMenu: _layananMenu,
            muatUlangKe: _muatUlangProfil,
          ),
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
        // State 1: Memuat (Loading). Saat pull-to-refresh, data lama masih
        // ada, jadi daftar tidak diganti spinner.
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
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
        final daftarMenu = _gabungkanDenganUsulan(snapshot.data ?? []);
        return HalamanMenu(
          daftarMenu: daftarMenu,
          onTambah: _tambahKeKeranjang,
          onRefresh: _segarkanMenu,
        );
      },
    );
  }
}