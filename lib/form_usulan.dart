import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model_menu.dart';

/// Form usulan menu baru yang ditampilkan di dalam bottom sheet.
///
/// Jika dikirim, sheet ditutup dengan mengembalikan [Menu] hasil usulan.
class FormUsulan extends StatefulWidget {
  const FormUsulan({super.key});

  @override
  State<FormUsulan> createState() => _FormUsulanState();
}

class _FormUsulanState extends State<FormUsulan> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kantinController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  String _kategori = 'Makanan';

  /// Pesan error baru ditampilkan setelah pengguna mencoba mengirim.
  bool _sudahDicoba = false;

  List<TextEditingController> get _semuaController =>
      [_namaController, _kantinController, _hargaController];

  @override
  void initState() {
    super.initState();
    for (final controller in _semuaController) {
      controller.addListener(_saatTeksBerubah);
    }
  }

  @override
  void dispose() {
    for (final controller in _semuaController) {
      controller.removeListener(_saatTeksBerubah);
      controller.dispose();
    }
    super.dispose();
  }

  void _saatTeksBerubah() {
    // Hanya perlu build ulang agar pesan error ikut hilang saat diisi.
    if (_sudahDicoba) setState(() {});
  }

  String? _pesanError(TextEditingController controller) {
    if (!_sudahDicoba) return null;
    return controller.text.trim().isEmpty ? 'Wajib diisi' : null;
  }

  void _kirim() {
    final adaYangKosong =
        _semuaController.any((controller) => controller.text.trim().isEmpty);

    if (adaYangKosong) {
      setState(() {
        _sudahDicoba = true;
      });
      return;
    }

    final usulan = Menu(
      id: DateTime.now().millisecondsSinceEpoch,
      nama: _namaController.text.trim(),
      kantin: _kantinController.text.trim(),
      kategori: _kategori,
      harga: int.parse(_hargaController.text),
      tersedia: true,
      diperbarui: DateTime.now(),
      gambar: '',
    );

    Navigator.pop(context, usulan);
  }

  @override
  Widget build(BuildContext context) {
    // Geser form ke atas saat keyboard muncul.
    final tinggiKeyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + tinggiKeyboard),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Usulkan Menu Baru',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Menu yang kamu inginkan belum ada? Usulkan ke kantin.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nama menu',
                prefixIcon: const Icon(Icons.fastfood_outlined),
                border: const OutlineInputBorder(),
                errorText: _pesanError(_namaController),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kantinController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Kantin',
                hintText: 'contoh: Kantin A',
                prefixIcon: const Icon(Icons.storefront_outlined),
                border: const OutlineInputBorder(),
                errorText: _pesanError(_kantinController),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _kirim(),
              decoration: InputDecoration(
                labelText: 'Harga',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: const OutlineInputBorder(),
                errorText: _pesanError(_hargaController),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Makanan',
                  label: Text('Makanan'),
                  icon: Icon(Icons.rice_bowl),
                ),
                ButtonSegment(
                  value: 'Minuman',
                  label: Text('Minuman'),
                  icon: Icon(Icons.local_drink),
                ),
                ButtonSegment(
                  value: 'Camilan',
                  label: Text('Camilan'),
                  icon: Icon(Icons.cookie),
                ),
              ],
              selected: {_kategori},
              showSelectedIcon: false,
              onSelectionChanged: (pilihan) {
                setState(() {
                  _kategori = pilihan.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _kirim,
                    child: const Text('Kirim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
