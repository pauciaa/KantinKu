import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model_menu.dart';

/// Exception khusus untuk penanganan error HTTP dan JSON pada P07.
class LayananMenuException implements Exception {
  final String pesan;
  const LayananMenuException(this.pesan);

  @override
  String toString() => pesan;
}

/// Service layer HTTP & Parsing JSON sesuai spesifikasi P07 KantinKu.
class LayananMenu {
  final http.Client _client;

  static String get _baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return 'https://dummyjson.com/products';
  }

  LayananMenu({http.Client? client}) : _client = client ?? http.Client();

  /// 1. HTTP GET: Mengambil daftar menu utama (GET /menu atau GET /products)
  Future<List<Menu>> ambilMenu() async {
    try {
      final response = await _client.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decodedBody is List) {
          rawList = decodedBody;
        } else if (decodedBody is Map<String, dynamic>) {
          if (decodedBody.containsKey('products')) {
            rawList = decodedBody['products'] as List<dynamic>;
          } else if (decodedBody.containsKey('data')) {
            rawList = decodedBody['data'] as List<dynamic>;
          }
        }

        return rawList.map<Menu>((json) {
          final map = json as Map<String, dynamic>;
          if (map.containsKey('title') && map.containsKey('price')) {
            return Menu.fromDummyJson(map);
          }
          return Menu.fromJson(map);
        }).toList();
      } else {
        throw LayananMenuException(
          'Gagal memuat menu dari server (Kode Status: ${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw const LayananMenuException(
        'Gagal terhubung ke server. Pastikan koneksi internet perangkat aktif.',
      );
    } on FormatException catch (e) {
      throw LayananMenuException('Format data JSON tidak valid: ${e.message}');
    } catch (e) {
      if (e is LayananMenuException) rethrow;
      throw LayananMenuException('Terjadi kesalahan saat memproses data: $e');
    }
  }

  /// 2. HTTP GET: Mengambil satu item berdasarkan ID (GET /menu/:id)
  Future<Menu> ambilMenuBerdasarkanId(int id) async {
    try {
      final String urlDetail =
          _baseUrl.endsWith('/') ? '$_baseUrl$id' : '$_baseUrl/$id';

      final response = await _client.get(Uri.parse(urlDetail));

      if (response.statusCode == 200) {
        final Map<String, dynamic> map = jsonDecode(response.body);
        if (map.containsKey('title') && map.containsKey('price')) {
          return Menu.fromDummyJson(map);
        }
        return Menu.fromJson(map);
      } else {
        throw LayananMenuException(
          'Gagal memuat detail menu ID $id (Kode Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is LayananMenuException) rethrow;
      throw LayananMenuException('Gagal mengambil item ID $id: $e');
    }
  }

  /// 3. HTTP GET Endpoint Khas: GET /kantin
  Future<dynamic> ambilDaftarKantin() async {
    try {
      final String endpointKantin =
          _baseUrl.endsWith('/products') || _baseUrl.endsWith('/menu')
              ? _baseUrl.replaceAll(RegExp(r'/(products|menu)$'), '/kantin')
              : '$_baseUrl/kantin';

      final response = await _client.get(Uri.parse(endpointKantin));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      final daftarMenu = await ambilMenu();
      final Map<String, int> rekapKantin = {};
      for (final item in daftarMenu) {
        rekapKantin[item.kantin] = (rekapKantin[item.kantin] ?? 0) + 1;
      }
      return rekapKantin;
    } catch (e) {
      if (e is LayananMenuException) rethrow;
      throw LayananMenuException('Gagal mengambil data kantin: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}