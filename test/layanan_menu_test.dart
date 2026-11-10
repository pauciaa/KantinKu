import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kantinku/layanan_menu.dart';
import 'package:kantinku/main.dart';

void main() {
  testWidgets('menu dari respons HTTP ditampilkan di aplikasi', (
    tester,
  ) async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'dummyjson.com');
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

    await tester.pumpWidget(
      KantinKuP04App(layananMenu: LayananMenu(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nasi Goreng Demo'), findsOneWidget);
    expect(find.text('Rp30.000'), findsOneWidget);
    expect(find.text('Sumber: DummyJSON'), findsOneWidget);
  });

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