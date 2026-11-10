/// Mengubah angka menjadi format rupiah, contoh: 15000 -> Rp15.000.
String formatRupiah(int harga) {
  final hargaString = harga.toString();
  final hasil = StringBuffer();

  for (int i = 0; i < hargaString.length; i++) {
    hasil.write(hargaString[i]);

    final sisa = hargaString.length - i - 1;

    if (sisa > 0 && sisa % 3 == 0) {
      hasil.write('.');
    }
  }

  return 'Rp${hasil.toString()}';
}
