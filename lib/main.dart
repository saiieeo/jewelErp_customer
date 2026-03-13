import 'package:flutter/material.dart';
import 'package:jewel_app/core/theme/app_theme.dart';
import 'features/auth/ui/splash_screen.dart'; 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JewelApp());
}

class JewelApp extends StatelessWidget {
  const JewelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JewelERP Customer',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.darkTheme, 
      
    
      home: const SplashScreen(),
    );
  }
}