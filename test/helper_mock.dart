import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Contoh data dengan format yang sama seperti server/data/menu.json.
List<Map<String, dynamic>> contohMenuJson() => [
      {
        'id': 1,
        'nama': 'Nasi Ayam Goreng',
        'kantin': 'Kantin A',
        'kategori': 'Makanan',
        'harga': 15000,
        'tersedia': true,
        'diperbarui': '2026-11-10T07:30:00.000',
        'gambar': '',
      },
      {
        'id': 2,
        'nama': 'Es Teh',
        'kantin': 'Kantin A',
        'kategori': 'Minuman',
        'harga': 4000,
        'tersedia': true,
        'diperbarui': '2026-11-10T07:30:00.000',
        'gambar': '',
      },
      {
        'id': 3,
        'nama': 'Tahu Isi',
        'kantin': 'Kantin C',
        'kategori': 'Camilan',
        'harga': 4000,
        'tersedia': false,
        'diperbarui': '2026-11-08T09:15:00.000',
        'gambar': '',
      },
    ];

http.Response responsJson(Object data, {int status = 200}) {
  return http.Response(
    jsonEncode(data),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// MockClient yang meniru server KantinKu: GET /menu, GET /menu/{id},
/// GET /kantin, dan POST /menu. Semua request dicatat di [riwayat].
MockClient buatMockServer({List<http.Request>? riwayat}) {
  final data = contohMenuJson();

  return MockClient((request) async {
    riwayat?.add(request);
    final path = request.url.path;

    if (request.method == 'GET' && path == '/menu') {
      return responsJson(data);
    }
    if (request.method == 'GET' && path.startsWith('/menu/')) {
      final id = int.parse(path.split('/').last);
      final menu = data.where((m) => m['id'] == id);
      return menu.isEmpty
          ? responsJson({'pesan': 'tidak ditemukan'}, status: 404)
          : responsJson(menu.first);
    }
    if (request.method == 'GET' && path == '/kantin') {
      return responsJson([
        {'nama': 'Kantin A', 'jumlahMenu': 2},
        {'nama': 'Kantin C', 'jumlahMenu': 1},
      ]);
    }
    if (request.method == 'POST' && path == '/menu') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final baru = {
        ...body,
        'id': 100,
        'diperbarui': '2026-11-11T12:00:00.000',
      };
      data.insert(0, baru);
      return responsJson(baru, status: 201);
    }
    return responsJson({'pesan': 'tidak ditemukan'}, status: 404);
  });
}
