import 'package:flutter/material.dart';

import 'halaman_utama.dart';

void main() {
  runApp(const KantinKuP04App());
}

class KantinKuP04App extends StatelessWidget {
  const KantinKuP04App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KantinKu P04',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        useMaterial3: true,
      ),
      home: const HalamanUtama(),
    );
  }
}
