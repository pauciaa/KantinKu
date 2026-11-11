import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kantinku/layanan_menu.dart';
import 'package:kantinku/model_menu.dart';

import 'helper_mock.dart';

/// Unit test LayananMenu memakai MockClient, tanpa server sungguhan.
void main() {
  const alamat = 'http://server-tes:8080';

  test('GET /menu diubah menjadi daftar Menu, termasuk DateTime', () async {
    final riwayat = <http.Request>[];
    final layanan = LayananMenu(
      client: buatMockServer(riwayat: riwayat),
      baseUrl: alamat,
    );
    addTearDown(layanan.dispose);

    final daftar = await layanan.ambilMenu();

    expect(riwayat.single.url.toString(), '$alamat/menu');
    expect(daftar, hasLength(3));
    expect(daftar.first.nama, 'Nasi Ayam Goreng');
    expect(daftar.first.diperbarui, DateTime(2026, 11, 10, 7, 30));
    expect(daftar.last.tersedia, isFalse);
  });

  test('GET /menu/{id} mengambil satu menu', () async {
    final layanan = LayananMenu(client: buatMockServer(), baseUrl: alamat);
    addTearDown(layanan.dispose);

    final menu = await layanan.ambilMenuBerdasarkanId(2);

    expect(menu.nama, 'Es Teh');
    expect(menu.harga, 4000);
  });

  test('GET /kantin mengembalikan jumlah menu per kantin', () async {
    final layanan = LayananMenu(client: buatMockServer(), baseUrl: alamat);
    addTearDown(layanan.dispose);

    final daftar = await layanan.ambilDaftarKantin();

    expect(daftar.map((k) => k.nama), ['Kantin A', 'Kantin C']);
    expect(daftar.first.jumlahMenu, 2);
  });

  test('POST /menu mengirim usulan sebagai JSON', () async {
    final riwayat = <http.Request>[];
    final layanan = LayananMenu(
      client: buatMockServer(riwayat: riwayat),
      baseUrl: alamat,
    );
    addTearDown(layanan.dispose);

    final tersimpan = await layanan.kirimUsulan(Menu(
      id: 0,
      nama: 'Seblak',
      kantin: 'Kantin D',
      kategori: 'Makanan',
      harga: 12000,
      tersedia: true,
      diperbarui: DateTime(2026, 11, 11),
      gambar: '',
    ));

    final request = riwayat.single;
    expect(request.method, 'POST');
    expect(jsonDecode(request.body)['nama'], 'Seblak');
    expect(tersimpan.id, 100);
  });

  test('server error menghasilkan pesan error yang jelas', () async {
    final layanan = LayananMenu(
      client: MockClient((_) async => http.Response('Server error', 503)),
      baseUrl: alamat,
    );
    addTearDown(layanan.dispose);

    await expectLater(
      layanan.ambilMenu(),
      throwsA(isA<LayananMenuException>()
          .having((e) => e.pesan, 'pesan', contains('503'))),
    );
  });

  test('server mati menghasilkan LayananMenuException', () async {
    final layanan = LayananMenu(
      client: MockClient(
        (_) async => throw http.ClientException('Connection refused'),
      ),
      baseUrl: alamat,
    );
    addTearDown(layanan.dispose);

    await expectLater(
      layanan.ambilMenu(),
      throwsA(isA<LayananMenuException>()
          .having((e) => e.pesan, 'pesan', contains('server'))),
    );
  });

  test('toJson lalu fromJson menghasilkan data yang sama', () {
    final menu = Menu.fromJson(contohMenuJson().first);
    final ulang = Menu.fromJson(menu.toJson());

    expect(ulang.nama, menu.nama);
    expect(ulang.diperbarui, menu.diperbarui);
    expect(menu.toJson()['diperbarui'], '2026-11-10T07:30:00.000');
  });
}
