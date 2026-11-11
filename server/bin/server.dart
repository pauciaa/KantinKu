import 'dart:convert';
import 'dart:io';

import 'package:kantinku_server/kantinku_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Menjalankan server KantinKu.
///
///   cd server
///   dart pub get
///   dart run bin/server.dart
///
/// Port bisa diganti lewat variabel lingkungan PORT (bawaan 8080).
Future<void> main() async {
  final daftarMenu = await _bacaDataAwal();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(buatRouter(daftarMenu).call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('KantinKu API berjalan di http://localhost:${server.port}');
  print('Data awal: ${daftarMenu.length} menu');
}

/// Membaca data/kantinku.json, baik saat dijalankan dari folder server/
/// maupun dari folder lain.
Future<List<Map<String, dynamic>>> _bacaDataAwal() async {
  final kandidat = [
    File('data/kantinku.json'),
    File.fromUri(Platform.script.resolve('../data/kantinku.json')),
  ];
  for (final file in kandidat) {
    if (await file.exists()) {
      final isi = jsonDecode(await file.readAsString()) as List<dynamic>;
      return isi.cast<Map<String, dynamic>>();
    }
  }
  throw StateError('File data/kantinku.json tidak ditemukan');
}
