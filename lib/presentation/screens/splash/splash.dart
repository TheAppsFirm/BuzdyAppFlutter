import 'package:buzdy/presentation/screens/dashboard.dart';
import 'package:buzdy/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    // Check token and navigate accordingly
    Future.delayed(const Duration(seconds: 3), () async {
      await _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Always navigate directly to the dashboard.  Authentication
    // is temporarily disabled so we skip any token checks.
    Get.offAll(() => const DashBoard(index: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appButtonColor, // or any color you like
      body: SizedBox.expand(
        // this will make sure it takes full screen
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'images/buzdysplash.png',
              fit: BoxFit.cover, // <--- makes sure it fills the screen
            ),
          ),
        ),
      ),
    );
  }
}
