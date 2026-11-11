import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model_kantin.dart';
import 'model_menu.dart';

/// Exception dengan pesan yang siap ditampilkan ke pengguna.
class LayananMenuException implements Exception {
  final String pesan;
  const LayananMenuException(this.pesan);

  @override
  String toString() => pesan;
}

/// Layanan HTTP untuk server KantinKu (folder server/).
///
/// Alamat server dibaca dari `--dart-define=API_URL=...`. Tanpa itu, dipakai
/// `http://10.0.2.2:8080`, yaitu alamat komputer dilihat dari emulator Android.
class LayananMenu {
  static const String alamatBawaan = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration _batasWaktu = Duration(seconds: 10);

  final http.Client _client;
  final String baseUrl;

  LayananMenu({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = (baseUrl ?? alamatBawaan).replaceAll(RegExp(r'/+$'), '');

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// GET /menu: daftar semua menu.
  Future<List<Menu>> ambilMenu() async {
    final data = await _get('/menu');
    if (data is! List) {
      throw const LayananMenuException('Format data menu dari server tidak valid.');
    }
    return data
        .map((json) => Menu.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /menu/{id}: satu menu berdasarkan id.
  Future<Menu> ambilMenuBerdasarkanId(int id) async {
    final data = await _get('/menu/$id');
    return Menu.fromJson(data as Map<String, dynamic>);
  }

  /// GET /kantin: daftar kantin beserta jumlah menunya.
  Future<List<Kantin>> ambilDaftarKantin() async {
    final data = await _get('/kantin') as List<dynamic>;
    return data
        .map((json) => Kantin.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /menu: mengirim usulan menu baru. Server membalas menu yang
  /// tersimpan, lengkap dengan id dari server.
  Future<Menu> kirimUsulan(Menu usulan) async {
    final response = await _kirim(
      () => _client.post(
        _uri('/menu'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(usulan.toJson()),
      ),
    );
    if (response.statusCode != 201) {
      throw LayananMenuException(
        'Usulan ditolak server (Kode Status: ${response.statusCode})',
      );
    }
    return Menu.fromJson(_decode(response.body) as Map<String, dynamic>);
  }

  Future<Object?> _get(String path) async {
    final response = await _kirim(() => _client.get(_uri(path)));
    if (response.statusCode != 200) {
      throw LayananMenuException(
        'Gagal memuat data dari server (Kode Status: ${response.statusCode})',
      );
    }
    return _decode(response.body);
  }

  Future<http.Response> _kirim(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_batasWaktu);
    } on TimeoutException {
      throw const LayananMenuException(
        'Server tidak merespons. Pastikan server KantinKu sudah dinyalakan.',
      );
    } on http.ClientException {
      throw LayananMenuException(
        'Gagal terhubung ke server ($baseUrl). '
        'Pastikan server KantinKu sudah dinyalakan.',
      );
    }
  }

  Object? _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw LayananMenuException('Format data JSON tidak valid: ${e.message}');
    }
  }

  void dispose() {
    _client.close();
  }
}
