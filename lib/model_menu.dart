class Menu {
  final String id;
  final String nama;
  final String kantin;
  final String kategori;
  final int harga;
  final bool tersedia;
  final DateTime diperbarui;
  final String gambar;

  // Constructor
  Menu({
    required this.id,
    required this.nama,
    required this.kantin,
    required this.kategori,
    required this.harga,
    required this.tersedia,
    required this.diperbarui,
    required this.gambar,
  });

  // Mengubah JSON menjadi objek Menu
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kantin: json['kantin'] as String,
      kategori: json['kategori'] as String,
      harga: (json['harga'] as num).toInt(),
      tersedia: json['tersedia'] as bool,
      diperbarui: DateTime.parse(json['diperbarui'] as String),
      gambar: json['gambar'] as String,
    );
  }

  // Mengubah objek Menu menjadi Map JSON
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
