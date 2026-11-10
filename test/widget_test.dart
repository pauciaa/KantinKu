import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kantinku/halaman_detail_menu.dart';
import 'package:kantinku/halaman_utama.dart';
import 'package:kantinku/model_menu.dart';

void main() {
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

  testWidgets('Ketuk kartu menu membuka halaman detail', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HalamanUtama()));

    await tester.tap(find.text('Nasi Goreng'));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanDetailMenu), findsOneWidget);
  });

  testWidgets('Usulan dari form langsung muncul di daftar menu',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HalamanUtama()));

    await tester.tap(find.text('Usulkan Menu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Seblak');
    await tester.enterText(find.byType(TextField).at(1), 'Kantin D');
    await tester.enterText(find.byType(TextField).at(2), '12000');
    await tester.tap(find.text('Kirim'));
    await tester.pumpAndSettle();

    expect(find.text('Seblak'), findsOneWidget);
  });
}
