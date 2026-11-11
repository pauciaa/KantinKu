import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kantinku/halaman_detail_menu.dart';
import 'package:kantinku/layanan_menu.dart';
import 'package:kantinku/main.dart';
import 'package:kantinku/model_menu.dart';

import 'helper_mock.dart';

void main() {
  Future<void> bukaAplikasi(WidgetTester tester, http.Client client) async {
    await tester.pumpWidget(
      KantinKuP04App(
        layananMenu: LayananMenu(client: client, baseUrl: 'http://tes'),
      ),
    );
    await tester.pumpAndSettle();
  }

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

  testWidgets('Menu dari server (MockClient) tampil, yang habis diberi label',
      (tester) async {
    await bukaAplikasi(tester, buatMockServer());

    expect(find.text('Nasi Ayam Goreng'), findsOneWidget);
    expect(find.text('Rp15.000'), findsOneWidget);
    expect(find.text('Tahu Isi'), findsOneWidget);
    expect(find.text('Habis'), findsOneWidget);
  });

  testWidgets('Ketuk kartu menu membuka halaman detail dengan Hero',
      (tester) async {
    await bukaAplikasi(tester, buatMockServer());

    expect(find.byType(Hero), findsWidgets);
    await tester.tap(find.text('Es Teh'));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanDetailMenu), findsOneWidget);
  });

  testWidgets('Usulan dari form langsung muncul di daftar dan dikirim POST',
      (tester) async {
    final riwayat = <http.Request>[];
    await bukaAplikasi(tester, buatMockServer(riwayat: riwayat));

    await tester.tap(find.text('Usulkan Menu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Seblak');
    await tester.enterText(find.byType(TextField).at(1), 'Kantin D');
    await tester.enterText(find.byType(TextField).at(2), '12000');
    await tester.tap(find.text('Kirim'));
    await tester.pumpAndSettle();

    expect(find.text('Seblak'), findsOneWidget);
    expect(riwayat.where((r) => r.method == 'POST'), hasLength(1));
  });

  testWidgets('Gagal memuat menampilkan Coba lagi, lalu berhasil',
      (tester) async {
    var serverHidup = false;
    final client = MockClient((request) async {
      if (!serverHidup) throw http.ClientException('Connection refused');
      return responsJson(contohMenuJson());
    });

    await bukaAplikasi(tester, client);
    expect(find.text('Menu gagal dimuat'), findsOneWidget);

    serverHidup = true;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Menu gagal dimuat'), findsNothing);
    expect(find.text('Nasi Ayam Goreng'), findsOneWidget);
  });

  testWidgets('Tarik ke bawah (pull-to-refresh) memuat data terbaru',
      (tester) async {
    var jumlahPanggilan = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/kantin') {
        return responsJson([
          {'nama': 'Kantin A', 'jumlahMenu': 2},
        ]);
      }
      jumlahPanggilan++;
      final data = contohMenuJson();
      if (jumlahPanggilan > 1) {
        data.insert(0, {...data.first, 'id': 50, 'nama': 'Menu Baru Server'});
      }
      return responsJson(data);
    });

    await bukaAplikasi(tester, client);
    expect(find.text('Menu Baru Server'), findsNothing);

    await tester.fling(find.text('Nasi Ayam Goreng'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(jumlahPanggilan, 2);
    expect(find.text('Menu Baru Server'), findsOneWidget);
  });

  testWidgets('ChoiceChip kategori memfilter daftar menu', (tester) async {
    await bukaAplikasi(tester, buatMockServer());

    await tester.tap(find.widgetWithText(ChoiceChip, 'Minuman'));
    await tester.pumpAndSettle();

    expect(find.text('Es Teh'), findsOneWidget);
    expect(find.text('Nasi Ayam Goreng'), findsNothing);
  });

  testWidgets('Tombol tambah/kurang di keranjang mengubah total harga',
      (tester) async {
    await bukaAplikasi(tester, buatMockServer());

    await tester.tap(find.byTooltip('Tambah ke keranjang').first);
    await tester.pump();
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Rp15.000'), findsNWidgets(2)); // subtotal + total

    await tester.tap(find.byTooltip('Tambah'));
    await tester.pump();
    expect(find.text('Rp30.000'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Kurangi'));
    await tester.pump();
    expect(find.text('Rp15.000'), findsNWidgets(2));
  });

  testWidgets('Tab Profil menampilkan logo aset dan daftar dari GET /kantin',
      (tester) async {
    await bukaAplikasi(tester, buatMockServer());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.image(const AssetImage('assets/images/logo.png')), findsOneWidget);
    expect(find.text('Kantin A'), findsOneWidget);
    expect(find.text('2 menu'), findsOneWidget);
  });

  testWidgets('Tombol di AppBar mengganti mode terang dan gelap',
      (tester) async {
    await bukaAplikasi(tester, buatMockServer());
    Brightness temaSekarang() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    expect(temaSekarang(), Brightness.light);

    await tester.tap(find.byTooltip('Mode gelap'));
    await tester.pumpAndSettle();
    expect(temaSekarang(), Brightness.dark);

    await tester.tap(find.byTooltip('Mode terang'));
    await tester.pumpAndSettle();
    expect(temaSekarang(), Brightness.light);
  });
}
