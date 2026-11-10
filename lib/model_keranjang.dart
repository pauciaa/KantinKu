import 'model_menu.dart';

/// Satu baris di keranjang: menu yang dipesan beserta jumlahnya.
class ItemPesanan {
  final Menu menu;
  int jumlah;

  ItemPesanan({
    required this.menu,
    this.jumlah = 1,
  });

  int get subtotal => menu.harga * jumlah;
}
