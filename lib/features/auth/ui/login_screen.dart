import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_discovery_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  
                  // --- Branded SVG Logo Container ---
                  _buildLogoHeader(),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    "JewelFlow",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF5F5F5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 60),

                  // --- Field 1: Customer ID ---
                  _buildLoginField(
                    label: "CUSTOMER ID",
                    controller: _idController,
                    hint: "e.g. 100245",
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? "Enter your ID" : null,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // --- Field 2: Password ---
                  _buildLoginField(
                    label: "PASSWORD",
                    controller: _passwordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    validator: (v) => (v == null || v.isEmpty) ? "Enter password" : null,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login Button
                  _buildLoginButton(),
                  
                  const SizedBox(height: 40),
                  
                  // Navigation to Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Component Helpers ---

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        color: const Color(0xFF16213E).withOpacity(0.5),
      ),
      child: SvgPicture.asset('assets/logo.svg', width: 35, height: 35),
    );
  }

  Widget _buildLoginField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: const Color(0xFFD4AF37), 
            letterSpacing: 1.2
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && !(isPasswordVisible ?? false),
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withOpacity(0.7), size: 20),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible! ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF6C6C80),
                    size: 18,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
            fillColor: const Color(0xFF16213E).withOpacity(0.4),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF16213E)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const ShopDiscoveryScreen()),
    (route) => false, // This clears the login stack so they can't go back to login
  );
}
        },
        child: const Text(
          "ENTER THE VAULT",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
      ),
    );
  }
}