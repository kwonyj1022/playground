import 'package:flutter/material.dart';
import 'package:seeso_flutter/event/gaze_info.dart';
import 'package:seeso_flutter/seeso.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EyeTrackingScreen(),
    );
  }
}


class EyeTrackingScreen extends StatefulWidget {
  const EyeTrackingScreen({super.key});

  @override
  State<EyeTrackingScreen> createState() => _EyeTrackingScreenState();
}

class _EyeTrackingScreenState extends State<EyeTrackingScreen> {
  final SeeSo _seeso = SeeSo();
  double _gazeX = 0;
  double _gazeY = 0;

  @override
  void initState() {
    super.initState();
    _initEyeTracking();
  }

  Future<void> _initEyeTracking() async {
    final hasPermission = await _seeso.checkCameraPermission();
    if (!hasPermission) {
      await _seeso.requestCameraPermission();
    }

    const licenseKey = 'lisenseKey'; // TODO: seeso.io에서 발급받은 키
    await _seeso.initGazeTracker(licenseKey: licenseKey);

    _seeso.startTracking();

    _seeso.getGazeEvent().listen((event) {
      final gazeInfo = GazeInfo(event);
      if (gazeInfo.trackingState == TrackingState.SUCCESS) {
        setState(() {

          _gazeX = gazeInfo.x;
          _gazeY = gazeInfo.y;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('시선 추적 영역')),

          // 시선 위치 표시용 빨간 점
          Positioned(
            left: _gazeX - 10,  // 점의 중심 정렬
            top: _gazeY - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _seeso.stopTracking();
    super.dispose();
  }
}
