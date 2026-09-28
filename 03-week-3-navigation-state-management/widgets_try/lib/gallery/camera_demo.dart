import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraDemo extends StatefulWidget {
  const CameraDemo({super.key});

  @override
  State<CameraDemo> createState() => _CameraDemoState();
}

class _CameraDemoState extends State<CameraDemo>
    with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kamera hanya hidup selagi halaman ini aktif. Saat aplikasi masuk ke
    // background, kamera dilepas; saat kembali, kamera dinyalakan ulang.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _releaseCamera();
    } else if (state == AppLifecycleState.resumed && !_isReady) {
      _initCamera();
    }
  }

  void _releaseCamera() {
    final c = controller;
    controller = null;
    if (mounted) {
      setState(() {
        _isReady = false;
      });
    }
    c?.dispose();
  }

  Future<void> _initCamera() async {
    try {
      // Mengambil daftar kamera yang tersedia di perangkat.
      // Catatan: ini memicu permintaan izin & menyalakan kamera, jadi
      // hanya dipanggil saat halaman Kamera dibuka.
      _cameras = await availableCameras();

      if (_cameras != null && _cameras!.isNotEmpty) {
        // Inisialisasi kamera pertama (biasanya kamera belakang)
        final newController =
            CameraController(_cameras![0], ResolutionPreset.max);
        controller = newController;
        await newController.initialize();

        // Bisa jadi halaman sudah ditutup / app masuk background saat
        // inisialisasi berjalan — kalau begitu, langsung lepas kameranya.
        if (!mounted || !identical(controller, newController)) {
          await newController.dispose();
          return;
        }
        setState(() {
          _isReady = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang terdeteksi. '
              'Di web/desktop kamera mungkin tidak tersedia — coba jalankan di HP.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengakses kamera: $e\n\n'
              'Pastikan izin kamera sudah diberikan dan perangkat '
              'memiliki kamera (web/desktop mungkin tidak punya).';
        });
      }
    }
  }

  /// Menampilkan pesan ramah saat kamera tidak bisa dipakai,
  /// supaya halaman tidak hanya berputar-putar tanpa penjelasan.
  Widget _buildMessage(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = '';
                _isReady = false;
              });
              _initCamera();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Camera')),
      body: Center(
        child: _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage.isNotEmpty) {
      return _buildMessage(_errorMessage, Icons.no_photography);
    }
    
    if (!_isReady || controller == null || !controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    
    return CameraPreview(controller!);
  }
}
