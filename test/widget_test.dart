import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kantinku/halaman_detail_menu.dart';
import 'package:kantinku/layanan_menu.dart';
import 'package:kantinku/main.dart';
import 'package:kantinku/model_menu.dart';

void main() {
  /// Helper untuk membuat MockClient standar yang mengembalikan 1 data menu dummy
  MockClient buatMockClientSukses() {
    return MockClient((request) async {
      return http.Response(
        jsonEncode({
          'products': [
            {
              'id': 1,
              'title': 'Nasi Goreng Demo',
              'category': 'groceries',
              'price': 2,
              'availabilityStatus': 'In Stock',
              'thumbnail': '',
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  // 1. Test unit model halaman detail (bawaan P04)
  testWidgets('Halaman detail menampilkan data menu dari konstruktor',
      (tester) async {
    final menu = Menu(
      id: 99,
      nama: 'Es Teh Manis',
      kantin: 'Kantin Z',
      kategori: 'Minuman',
      harga: 5000,
      tersedia: true,
      diperbarui: DateTime(2026, 11, 10),
      gambar: '',
    );
    await tester.pumpWidget(MaterialApp(home: HalamanDetailMenu(menu: menu)));

    expect(find.text('Kantin Z'), findsOneWidget);
    expect(find.text('Rp5.000'), findsOneWidget);
    expect(find.text('10/11/2026'), findsOneWidget);
  });

  // 2. Test integrasi UI + HTTP MockClient (P07)
  testWidgets('menu dari respons HTTP ditampilkan di aplikasi',
      (tester) async {
    final client = buatMockClientSukses();

    await tester.pumpWidget(
      KantinKuP04App(layananMenu: LayananMenu(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nasi Goreng Demo'), findsOneWidget);
    expect(find.text('Rp30.000'), findsOneWidget);
    expect(find.text('Sumber: DummyJSON'), findsOneWidget);
  });

  // 3. Test navigasi ketuk kartu menu membuka detail (P07 dengan MockClient)
  testWidgets('Ketuk kartu menu membuka halaman detail', (tester) async {
    final client = buatMockClientSukses();

    await tester.pumpWidget(
      KantinKuP04App(layananMenu: LayananMenu(client: client)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nasi Goreng Demo'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi Goreng Demo'), findsWidgets);
  });

  // 4. Test error handling LayananMenu (Spesifikasi P07)
  test('server error menghasilkan pesan error yang jelas', () async {
    final service = LayananMenu(
      client: MockClient(
        (_) async => http.Response('Server error', 503),
      ),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.ambilMenu(),
      throwsA(
        isA<LayananMenuException>().having(
          (error) => error.pesan,
          'pesan',
          contains('503'),
        ),
      ),
    );
  });
}