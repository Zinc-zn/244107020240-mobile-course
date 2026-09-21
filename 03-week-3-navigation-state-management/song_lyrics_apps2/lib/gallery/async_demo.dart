import 'package:flutter/material.dart';
import 'dart:async';

class AsyncDemo extends StatelessWidget {
  const AsyncDemo({super.key});

  Future<String> fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'Data berhasil dimuat dari Future!';
  }

  Stream<int> counterStream() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async & State Widgets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('FutureBuilder Demo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(snapshot.data ?? '');
                }
              },
            ),
            const Divider(height: 32),
            const Text('StreamBuilder Demo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: counterStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Menunggu stream dimulai...');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return const Text('Stream selesai!');
                } else {
                  return Text('Stream value: ${snapshot.data}', style: const TextStyle(fontSize: 24));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
