/// Satu baris dari endpoint GET /kantin.
class Kantin {
  final String nama;
  final int jumlahMenu;

  const Kantin({required this.nama, required this.jumlahMenu});

  factory Kantin.fromJson(Map<String, dynamic> json) {
    return Kantin(
      nama: json['nama'] as String,
      jumlahMenu: json['jumlahMenu'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'nama': nama, 'jumlahMenu': jumlahMenu};
}
