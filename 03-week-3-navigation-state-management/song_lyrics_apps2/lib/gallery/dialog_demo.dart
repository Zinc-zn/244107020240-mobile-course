import 'package:flutter/material.dart';

class DialogDemo extends StatelessWidget {
  const DialogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog & Feedback')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('AlertDialog'),
                    content: const Text('Ini adalah contoh AlertDialog'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))
                    ],
                  ),
                );
              },
              child: const Text('Tampilkan AlertDialog'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ini adalah SnackBar!')),
                );
              },
              child: const Text('Tampilkan SnackBar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    color: Colors.white,
                    child: const Center(child: Text('Ini BottomSheet')),
                  ),
                );
              },
              child: const Text('Tampilkan BottomSheet'),
            ),
            const SizedBox(height: 16),
            const Tooltip(
              message: 'Ini adalah tooltip',
              child: Icon(Icons.info, size: 50),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
