import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grow Forest with Fitness",
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: const Walking(),
    );
  }
}

class Walking extends StatefulWidget {
  const Walking({super.key});

  @override
  State<Walking> createState() => _WalkingState();
}

class _WalkingState extends State<Walking> with TickerProviderStateMixin {
  late AnimationController _walkingController;
  late Animation<double> _walkingAnimation;
  late AnimationController _treeController;
  late Stream<StepCount> _stepCountStream;

  String _steps = '0';

  int _stepTree = 0;

  final int _optimalSteps = 250;

  @override
  void initState() {
    super.initState();

    // Walking Animation
    _walkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _walkingAnimation = Tween<double>(begin: -150, end: 350).animate(
      CurvedAnimation(
        parent: _walkingController,
        curve: Curves.linear,
      ),
    );

    _walkingController.repeat();

    // Tree Animation
    _treeController = AnimationController(vsync: this)
      ..value = 0.0
      ..addListener(() {
        setState(() {});
      });

    // Pedometer
    _initPedoMeter();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
      _stepTree = int.parse(_steps);
      print('Steps calculated by pedometer: $_steps');
      print('Steps converted to integer: $_stepTree');

      double progress = (_stepTree / _optimalSteps).clamp(0.0, 1.0);
      _treeController.animateTo(progress,
          duration: const Duration(seconds: 20));
    });
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> _initPedoMeter() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      print('Permission not granted');
    }

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  void dispose() {
    _walkingController.dispose();
    _treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: screenHeight * 0.08,
              child: Lottie.asset(
                'assets/tree.json',
                width: screenWidth * 0.7,
                height: screenHeight * 0.3,
                fit: BoxFit.cover,
                controller: _treeController,
                onLoaded: (composition) {
                  setState(() {
                    _treeController.duration = composition.duration;
                  });
                },
              ),
            ),
            AnimatedBuilder(
              animation: _walkingAnimation,
              builder: (context, child) {
                return Positioned(
                  left: _walkingAnimation.value,
                  bottom: screenHeight * 0.46,
                  child: child!,
                );
              },
              child: Lottie.asset(
                'assets/walking.json',
                width: screenWidth * 0.35,
                height: screenHeight * 0.15,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.33,
              child: const Text(
                "Steps Count:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrains',
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.20,
              child: Text(
                _steps,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrains',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
