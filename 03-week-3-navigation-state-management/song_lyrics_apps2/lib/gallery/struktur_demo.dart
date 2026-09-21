import 'package:flutter/material.dart';

class StrukturDemo extends StatelessWidget {
  const StrukturDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold dan AppBar adalah bagian dari struktur
    return Scaffold(
      appBar: AppBar(title: const Text('Struktural & App')),
      // SafeArea memastikan konten tidak tertutup notch/status bar
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 150,
            height: 150,
            color: Colors.orange,
            child: const Center(
              child: Text(
                'Align BottomRight',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
