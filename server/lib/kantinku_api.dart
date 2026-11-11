import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

const _headerJson = {'content-type': 'application/json; charset=utf-8'};

/// Kategori yang boleh dipakai, sama dengan ChoiceChip di aplikasi.
const daftarKategori = ['Makanan', 'Minuman', 'Camilan'];

Response _json(Object? data, {int status = 200}) =>
    Response(status, body: jsonEncode(data), headers: _headerJson);

Response _gagal(int status, String pesan) => _json({'pesan': pesan}, status: status);

/// Membuat router API KantinKu. [daftarMenu] disimpan di memori, sehingga
/// menu yang ditambah lewat POST hilang saat server dimatikan.
Router buatRouter(List<Map<String, dynamic>> daftarMenu) {
  final router = Router();

  router.get('/', (Request request) {
    return _json({
      'nama': 'KantinKu API',
      'endpoint': [
        'GET /menu',
        'GET /menu/<id>',
        'GET /kantin',
        'POST /menu',
      ],
    });
  });

  // 1. Daftar semua menu.
  router.get('/menu', (Request request) => _json(daftarMenu));

  // 2. Satu menu berdasarkan id.
  router.get('/menu/<id|[0-9]+>', (Request request, String id) {
    final angka = int.parse(id);
    for (final menu in daftarMenu) {
      if (menu['id'] == angka) return _json(menu);
    }
    return _gagal(404, 'Menu dengan id $id tidak ditemukan');
  });

  // 3. Endpoint khas KantinKu: daftar kantin beserta jumlah menunya.
  router.get('/kantin', (Request request) {
    final jumlah = <String, int>{};
    for (final menu in daftarMenu) {
      final kantin = menu['kantin'] as String;
      jumlah[kantin] = (jumlah[kantin] ?? 0) + 1;
    }
    final hasil = jumlah.entries
        .map((e) => {'nama': e.key, 'jumlahMenu': e.value})
        .toList()
      ..sort((a, b) => (a['nama'] as String).compareTo(b['nama'] as String));
    return _json(hasil);
  });

  // Nilai tambah: menerima usulan menu baru dari form aplikasi.
  router.post('/menu', (Request request) async {
    final Object? data;
    try {
      data = jsonDecode(await request.readAsString());
    } on FormatException {
      return _gagal(400, 'Body harus berupa JSON');
    }
    if (data is! Map<String, dynamic>) {
      return _gagal(400, 'Body harus berupa objek JSON');
    }

    final nama = data['nama'];
    final kantin = data['kantin'];
    final kategori = data['kategori'];
    final harga = data['harga'];

    if (nama is! String || nama.trim().isEmpty) {
      return _gagal(400, 'Field "nama" wajib diisi');
    }
    if (kantin is! String || kantin.trim().isEmpty) {
      return _gagal(400, 'Field "kantin" wajib diisi');
    }
    if (kategori is! String || !daftarKategori.contains(kategori)) {
      return _gagal(400, 'Field "kategori" harus salah satu dari $daftarKategori');
    }
    if (harga is! int || harga <= 0) {
      return _gagal(400, 'Field "harga" harus bilangan bulat positif');
    }

    final idBaru = daftarMenu.fold<int>(
          0,
          (maks, menu) => (menu['id'] as int) > maks ? menu['id'] as int : maks,
        ) +
        1;

    final menuBaru = <String, dynamic>{
      'id': idBaru,
      'nama': nama.trim(),
      'kantin': kantin.trim(),
      'kategori': kategori,
      'harga': harga,
      'tersedia': data['tersedia'] is bool ? data['tersedia'] : true,
      'diperbarui': DateTime.now().toIso8601String(),
      'gambar': data['gambar'] is String ? data['gambar'] : '',
    };

    // Menu terbaru ditaruh paling atas.
    daftarMenu.insert(0, menuBaru);
    return _json(menuBaru, status: 201);
  });

  return router;
}

/// Mengizinkan akses dari Flutter web (Chrome) saat pengujian.
Middleware corsHeaders() {
  const header = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
  return (Handler inner) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: header);
      }
      final response = await inner(request);
      return response.change(headers: header);
    };
  };
}
