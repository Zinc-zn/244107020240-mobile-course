import 'package:flutter/material.dart';

class TextIconDemo extends StatelessWidget {
  const TextIconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teks & Ikon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ini adalah teks biasa dengan style.',
              style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, color: Colors.black),
                children: [
                  TextSpan(text: 'Ini '),
                  TextSpan(text: 'RichText ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'yang bisa multi-style.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SelectableText(
              'Teks ini bisa disorot (diselect) dan disalin.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 50),
                Icon(Icons.favorite, color: Colors.red, size: 50),
                Icon(Icons.flutter_dash, color: Colors.blue, size: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
