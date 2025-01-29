import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

class _WalkingState extends State<Walking> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _walkingAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _walkingAnimation = Tween<double>(begin: -150, end: 350).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              child: const Text(
                "10960",
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
