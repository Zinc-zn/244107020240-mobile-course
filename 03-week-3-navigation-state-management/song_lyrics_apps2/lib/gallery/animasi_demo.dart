import 'package:flutter/material.dart';

class AnimasiDemo extends StatefulWidget {
  const AnimasiDemo({super.key});

  @override
  State<AnimasiDemo> createState() => _AnimasiDemoState();
}

class _AnimasiDemoState extends State<AnimasiDemo> {
  bool _isExpanded = false;
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animasi Widgets')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              width: _isExpanded ? 200 : 100,
              height: _isExpanded ? 200 : 100,
              color: _isExpanded ? Colors.blue : Colors.red,
              curve: Curves.fastOutSlowIn,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: const Text('Animate Container'),
            ),
            const SizedBox(height: 32),
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: const Text('Teks ini bisa menghilang!', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              },
              child: const Text('Toggle Opacity'),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HeroDetailScreen()),
                );
              },
              child: Hero(
                tag: 'hero-tag',
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.green,
                ),
              ),
            ),
            const Text('Klik kotak hijau untuk Hero Animation'),
          ],
        ),
      ),
    );
  }
}

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail')),
      body: Center(
        child: Hero(
          tag: 'hero-tag',
          child: Container(
            width: 300,
            height: 300,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
