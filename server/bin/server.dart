import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  // Load data JSON
  final jsonFile = File('server/data/kantinku.json');
  final List<dynamic> menuList = jsonDecode(await jsonFile.readAsString());

  // 1. GET /api/menu (semua menu)
  router.get('/api/menu', (Request req) {
    return Response.ok(jsonEncode(menuList), headers: {'content-type': 'application/json'});
  });

  // 2. GET /api/menu/<id>
  router.get('/api/menu/<id>', (Request req, String id) {
    final item = menuList.firstWhere((e) => e['id'] == id, orElse: () => <String, dynamic>{});
    if (item.isEmpty) return Response.notFound('Menu tidak ditemukan');
    return Response.ok(jsonEncode(item), headers: {'content-type': 'application/json'});
  });

  // 3. GET /kantin (Endpoint khas: Daftar kantin & jumlah menunya)
  router.get('/kantin', (Request req) {
    final Map<String, int> kantinCount = {};
    for (var item in menuList) {
      final kantin = item['kantin'] as String;
      kantinCount[kantin] = (kantinCount[kantin] ?? 0) + 1;
    }
    final result = kantinCount.entries.map((e) => {'kantin': e.key, 'jumlah_menu': e.value}).toList();
    return Response.ok(jsonEncode(result), headers: {'content-type': 'application/json'});
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  stdout.writeln('Server KantinKu berjalan di http://${server.address.host}:${server.port}');
}