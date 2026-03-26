import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_dashboard.dart';
import 'dart:async';
import 'login_screen.dart'; 
import '../data/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Animation variables for a staggered, cinematic entrance
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up the premium animations
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1800)
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn))
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic))
    );

    // Start animation and then check auth
    _animController.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Give the animation time to play out fully (2.5 seconds feels premium)
    await Future.delayed(const Duration(milliseconds: 2500));

    // 2. Quietly check secure storage in the background
    final bool isUserLoggedIn = await AuthService().isLoggedIn();

    // 3. Prevent errors if the user closes the app during the splash
    if (!mounted) return;

    // 4. Smooth routing using PageRouteBuilder for a cross-fade transition
    if (isUserLoggedIn) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ShopDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child); // Smooth fade into dashboard
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child); // Smooth fade into login
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Matches your app theme perfectly
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            
            // --- The Animated Hero Section ---
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic)
                    ),
                    child: SvgPicture.asset(
                      'assets/logo.svg', 
                      width: 140,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Text(
                          "JewelERP",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "EXCLUSIVELY FOR YOU",
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD4AF37), 
                            letterSpacing: 5.0,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 3),
            
            // --- Minimalist Loading Indicator ---
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C6C80)), 
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}