import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraDemo extends StatefulWidget {
  const CameraDemo({super.key});

  @override
  State<CameraDemo> createState() => _CameraDemoState();
}

class _CameraDemoState extends State<CameraDemo> {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // Mengambil daftar kamera yang tersedia di perangkat
      _cameras = await availableCameras();
      
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Inisialisasi kamera pertama (biasanya kamera belakang)
        controller = CameraController(_cameras![0], ResolutionPreset.max);
        await controller!.initialize();
        
        if (!mounted) return;
        setState(() {
          _isReady = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang terdeteksi';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengakses kamera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
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
      return Text(_errorMessage, style: const TextStyle(color: Colors.red));
    }
    
    if (!_isReady || controller == null || !controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    
    return CameraPreview(controller!);
  }
}
