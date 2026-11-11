import 'dart:convert';

import 'package:kantinku_server/kantinku_api.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late Handler handler;

  setUp(() {
    final data = <Map<String, dynamic>>[
      {'id': 1, 'nama': 'Es Teh', 'kantin': 'Kantin A', 'kategori': 'Minuman', 'harga': 4000, 'tersedia': true, 'diperbarui': '2026-11-10T07:30:00.000', 'gambar': ''},
      {'id': 2, 'nama': 'Risol', 'kantin': 'Kantin B', 'kategori': 'Camilan', 'harga': 3000, 'tersedia': false, 'diperbarui': '2026-11-10T07:30:00.000', 'gambar': ''},
      {'id': 3, 'nama': 'Mie Ayam', 'kantin': 'Kantin B', 'kategori': 'Makanan', 'harga': 12000, 'tersedia': true, 'diperbarui': '2026-11-10T07:30:00.000', 'gambar': ''},
    ];
    handler = buatRouter(data).call;
  });

  Future<(int, Object?)> kirim(String method, String path, {Object? body}) async {
    final response = await handler(Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? null : jsonEncode(body),
    ));
    return (response.statusCode, jsonDecode(await response.readAsString()));
  }

  test('GET /menu mengembalikan semua menu', () async {
    final (status, body) = await kirim('GET', '/menu');
    expect(status, 200);
    expect(body, hasLength(3));
  });

  test('GET /menu/<id> mengembalikan satu menu atau 404', () async {
    final (status, body) = await kirim('GET', '/menu/2');
    expect(status, 200);
    expect((body as Map)['nama'], 'Risol');

    final (statusHilang, _) = await kirim('GET', '/menu/99');
    expect(statusHilang, 404);
  });

  test('GET /kantin menghitung jumlah menu per kantin', () async {
    final (status, body) = await kirim('GET', '/kantin');
    expect(status, 200);
    expect(body, [
      {'nama': 'Kantin A', 'jumlahMenu': 1},
      {'nama': 'Kantin B', 'jumlahMenu': 2},
    ]);
  });

  test('POST /menu menyimpan usulan dan memvalidasi input', () async {
    final (status, body) = await kirim('POST', '/menu', body: {
      'nama': 'Seblak',
      'kantin': 'Kantin D',
      'kategori': 'Makanan',
      'harga': 12000,
    });
    expect(status, 201);
    expect((body as Map)['id'], 4);

    final (_, daftar) = await kirim('GET', '/menu');
    expect((daftar as List).first['nama'], 'Seblak');

    final (statusSalah, _) = await kirim('POST', '/menu', body: {'nama': ''});
    expect(statusSalah, 400);
  });
}
