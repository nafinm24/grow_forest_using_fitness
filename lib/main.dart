import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';

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

  int _stepCount = 0;
  final int _totalSteps = 10000;

  @override
  void initState() {
    super.initState();

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

    _treeController = AnimationController(vsync: this);

    _initPedoMeter();
  }

  Future<void> _initPedoMeter() async {
    Pedometer.stepCountStream.listen((StepCount stepCount) {
      if (!mounted) return;
      setState(() {
        _stepCount = stepCount.steps;

        double progress = (_stepCount / _totalSteps).clamp(0.0, 1.0);
        _treeController.value = progress;
        if (kDebugMode) {
          print('Step Count: $_stepCount, Progress: $progress');
        }
      });
    }).onError((error) {
      if (kDebugMode) {
        print('Pedometer Error: $error');
      }
    });
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
              top: 30,
              child: Lottie.asset(
                'assets/tree.json',
                width: 330,
                height: 330,
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
                  bottom: 350,
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
                "$_stepCount",
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
