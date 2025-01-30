import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

void main() {
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

  final int _optimalSteps = 10000;

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
      print(_steps);
      print(_stepTree);
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
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 50,
              child: Lottie.asset(
                'assets/tree.json',
                width: 330,
                height: 330,
                fit: BoxFit.cover,
                controller: _treeController,
                onLoaded: (composition) {
                  setState(() {
                    _treeController.duration = composition.duration;
                    var start = 0.0;
                    var stop = 1.0;

                    // if (_stepTree > _optimalSteps) {
                    //   start = 0.0;
                    //   stop = 1.0;
                    // } else {
                    //   start = 0.0;
                    //   stop = (_stepTree / _optimalSteps);
                    // }
                    _treeController.repeat(
                      min: start,
                      max: stop,
                      reverse: true,
                      period: _treeController.duration! * (stop - start),
                    );
                  });
                },
              ),
            ),
            AnimatedBuilder(
              animation: _walkingAnimation,
              builder: (context, child) {
                return Positioned(
                  left: _walkingAnimation.value,
                  bottom: 390,
                  child: child!,
                );
              },
              child: Lottie.asset(
                'assets/walking.json',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 300,
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
              bottom: 220,
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
