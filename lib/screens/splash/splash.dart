import 'package:buzdy/screens/auth/login/login.dart';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:buzdy/views/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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

    // Initialize the animation controller with a longer duration for smoothness
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 3), // Slightly increased duration for smoother animation
    );

    // Define fade and scale animations with smoother timing
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: Curves.ease)); // Added easeInOut for smooth fade
    _scaleAnimation = Tween<double>(
            begin: 0.8, end: 1.0) // Reduced scale range for smooth scaling
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.ease)); // Added easeInOut for smooth scale

    // Start the animation
    _controller.forward();

    // Wait for 3 seconds and navigate to the next screen
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(LoginScreen());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(builder: (context, pr, c) {
      return Scaffold(
        backgroundColor: appButtonColor,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset('images/buzdysplash.png'),
              ),
            ),
          ),
        ),
      );
    });
  }
}
