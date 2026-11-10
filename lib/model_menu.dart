class Menu {
  final int id;
  final String nama;
  final String kantin;
  final String kategori;
  final int harga;
  final bool tersedia;
  final DateTime diperbarui;
  final String gambar;

  const Menu({
    required this.id,
    required this.nama,
    required this.kantin,
    required this.kategori,
    required this.harga,
    required this.tersedia,
    required this.diperbarui,
    required this.gambar,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int,
      nama: json['nama'] as String,
      kantin: json['kantin'] as String,
      kategori: json['kategori'] as String,
      harga: json['harga'] as int,
      tersedia: json['tersedia'] as bool,
      diperbarui: DateTime.parse(json['diperbarui'] as String),
      gambar: json['gambar'] as String? ?? '',
    );
  }

  factory Menu.fromDummyJson(Map<String, dynamic> json) {
    final price = json['price'];
    if (price is! num) {
      throw const FormatException('Harga menu dari API harus berupa angka.');
    }

    return Menu(
      id: json['id'] as int,
      nama: json['title'] as String,
      kantin: 'Sumber: DummyJSON',
      kategori: json['category'] as String,
      harga: (price * 15000).round(),
      tersedia: json['availabilityStatus'] != 'Out of Stock',
      diperbarui: DateTime.now(),
      gambar: json['thumbnail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kantin': kantin,
      'kategori': kategori,
      'harga': harga,
      'tersedia': tersedia,
      'diperbarui': diperbarui.toIso8601String(),
      'gambar': gambar,
    };
  }
}