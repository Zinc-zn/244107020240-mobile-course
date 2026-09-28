import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Defines the main theme color.
const Color themeMaterialColor = Color.fromRGBO(48, 49, 60, 1);

void main() {
  runApp(const MaterialApp(home: GeolocatorWidget()));
}

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {
  /// Creates a new GeolocatorWidget.
  const GeolocatorWidget({super.key});

  @override
  State<GeolocatorWidget> createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

  @override
  void initState() {
    super.initState();
    // getServiceStatusStream is NOT supported on web
    if (!kIsWeb) {
      _toggleServiceStatusStream();
    }
  }

  PopupMenuButton _createActions() {
    return PopupMenuButton(
      elevation: 40,
      onSelected: (value) async {
        switch (value) {
          case 1:
            _getLocationAccuracy();
            break;
          case 2:
            _requestTemporaryFullAccuracy();
            break;
          case 3:
            _openAppSettings();
            break;
          case 4:
            _openLocationSettings();
            break;
          case 5:
            setState(_positionItems.clear);
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        // dart:io Platform is not available on web
        final isIOS = !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS);
        final isAndroidOrWindows = !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.windows);
        return [
          if (isIOS)
            const PopupMenuItem(value: 1, child: Text("Get Location Accuracy")),
          if (isIOS)
            const PopupMenuItem(
              value: 2,
              child: Text("Request Temporary Full Accuracy"),
            ),
          const PopupMenuItem(value: 3, child: Text("Open App Settings")),
          if (isAndroidOrWindows)
            const PopupMenuItem(
                value: 4, child: Text("Open Location Settings")),
          const PopupMenuItem(value: 5, child: Text("Clear")),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 12);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF4ECCA3)),
            SizedBox(width: 8),
            Text('GPS Demo',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [_createActions()],
      ),
      body: Column(
        children: [
          // Platform banner
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0F3460),
            child: Row(
              children: [
                Icon(
                  kIsWeb ? Icons.language : Icons.smartphone,
                  color: const Color(0xFF4ECCA3),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  kIsWeb
                      ? 'Web — tekan tombol, lalu izinkan akses lokasi di browser'
                      : 'Mobile — full GPS support aktif',
                  style: const TextStyle(
                      color: Color(0xFF4ECCA3), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: _positionItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_searching,
                            size: 72, color: Color(0xFF4ECCA3)),
                        SizedBox(height: 16),
                        Text(
                          'Tekan tombol untuk mendapatkan lokasi',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _positionItems.length,
                    itemBuilder: (context, index) {
                      final positionItem = _positionItems[index];
                      if (positionItem.type == _PositionItemType.log) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F3460).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Color(0xFF4ECCA3)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  positionItem.displayValue,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF16213E),
                                Color(0xFF0F3460)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF4ECCA3), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_pin,
                                      color: Color(0xFF4ECCA3), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Posisi Ditemukan',
                                    style: TextStyle(
                                        color: Color(0xFF4ECCA3),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                positionItem.displayValue,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'stream',
            onPressed: () {
              positionStreamStarted = !positionStreamStarted;
              _toggleListening();
            },
            backgroundColor: _determineButtonColor(),
            icon: (_positionStreamSubscription == null ||
                    _positionStreamSubscription!.isPaused)
                ? const Icon(Icons.play_arrow, color: Colors.white)
                : const Icon(Icons.pause, color: Colors.white),
            label: Text(
              (_positionStreamSubscription == null)
                  ? 'Mulai Stream'
                  : _positionStreamSubscription!.isPaused
                      ? 'Lanjutkan'
                      : 'Jeda',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          sizedBox,
          FloatingActionButton.extended(
            heroTag: 'current',
            onPressed: _getCurrentPosition,
            backgroundColor: const Color(0xFF0F3460),
            icon: const Icon(Icons.my_location, color: Color(0xFF4ECCA3)),
            label: const Text('Lokasi Kini',
                style: TextStyle(color: Colors.white)),
          ),
          sizedBox,
          FloatingActionButton.extended(
            heroTag: 'last',
            onPressed: _getLastKnownPosition,
            backgroundColor: const Color(0xFF0F3460),
            icon: const Icon(Icons.history, color: Colors.orange),
            label: const Text('Terakhir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    _updatePositionList(_PositionItemType.position, position.toString());
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(_PositionItemType.log, _kPermissionDeniedMessage);

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(_PositionItemType.log, _kPermissionGrantedMessage);
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
  }

  bool _isListening() =>
      !(_positionStreamSubscription == null ||
          _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  void _toggleServiceStatusStream() {
    // Not supported on web — guard with kIsWeb before calling this
    if (kIsWeb) return;
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription = serviceStatusStream
          .handleError((error) {
            _serviceStatusStreamSubscription?.cancel();
            _serviceStatusStreamSubscription = null;
          })
          .listen((serviceStatus) {
            String serviceStatusValue;
            if (serviceStatus == ServiceStatus.enabled) {
              if (positionStreamStarted) {
                _toggleListening();
              }
              serviceStatusValue = 'enabled';
            } else {
              if (_positionStreamSubscription != null) {
                setState(() {
                  _positionStreamSubscription?.cancel();
                  _positionStreamSubscription = null;
                  _updatePositionList(
                    _PositionItemType.log,
                    'Position Stream has been canceled',
                  );
                });
              }
              serviceStatusValue = 'disabled';
            }
            _updatePositionList(
              _PositionItemType.log,
              'Location service has been $serviceStatusValue',
            );
          });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream
          .handleError((error) {
            _positionStreamSubscription?.cancel();
            _positionStreamSubscription = null;
          })
          .listen(
            (position) => _updatePositionList(
              _PositionItemType.position,
              position.toString(),
            ),
          );
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList(
        _PositionItemType.log,
        'Listening for position updates $statusDisplayValue',
      );
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  void _getLastKnownPosition() async {
    final position = await _geolocatorPlatform.getLastKnownPosition();
    if (position != null) {
      _updatePositionList(_PositionItemType.position, position.toString());
    } else {
      _updatePositionList(
        _PositionItemType.log,
        'No last known position available',
      );
    }
  }

  void _getLocationAccuracy() async {
    final status = await _geolocatorPlatform.getLocationAccuracy();
    _handleLocationAccuracyStatus(status);
  }

  void _requestTemporaryFullAccuracy() async {
    final status = await _geolocatorPlatform.requestTemporaryFullAccuracy(
      purposeKey: "TemporaryPreciseAccuracy",
    );
    _handleLocationAccuracyStatus(status);
  }

  void _handleLocationAccuracyStatus(LocationAccuracyStatus status) {
    String locationAccuracyStatusValue;
    if (status == LocationAccuracyStatus.precise) {
      locationAccuracyStatusValue = 'Precise';
    } else if (status == LocationAccuracyStatus.reduced) {
      locationAccuracyStatusValue = 'Reduced';
    } else {
      locationAccuracyStatusValue = 'Unknown';
    }
    _updatePositionList(
      _PositionItemType.log,
      '$locationAccuracyStatusValue location accuracy granted.',
    );
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Application Settings.';
    } else {
      displayValue = 'Error opening Application Settings.';
    }

    _updatePositionList(_PositionItemType.log, displayValue);
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Location Settings';
    } else {
      displayValue = 'Error opening Location Settings';
    }

    _updatePositionList(_PositionItemType.log, displayValue);
  }
}

enum _PositionItemType { log, position }

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}
