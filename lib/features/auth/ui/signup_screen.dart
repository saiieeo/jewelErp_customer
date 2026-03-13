import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_discovery_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // Essential Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
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
                  const SizedBox(height: 50),
                  
                  // --- Branded SVG Logo ---
                  _buildLogoHeader(),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    "Create Account",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Join the elite circle of JewelFlow.",
                    style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14),
                  ),
                  
                  const SizedBox(height: 40),

                  // --- Field 1: Full Name ---
                  _buildSignupField(
                    label: "FULL NAME",
                    controller: _nameController,
                    hint: "Enter your name",
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v!.isEmpty ? "Name is required" : null,
                  ),
                  
                  const SizedBox(height: 20),

                  // --- Field 2: Email Address ---
                  _buildSignupField(
                    label: "EMAIL ADDRESS",
                    controller: _emailController,
                    hint: "name@luxury.com",
                    icon: Icons.email_outlined,
                    validator: (v) => (v == null || !v.contains('@')) ? "Invalid email" : null,
                  ),
                  
                  const SizedBox(height: 20),

                  // --- Field 3: Phone Number ---
                  _buildSignupField(
                    label: "PHONE NUMBER",
                    controller: _phoneController,
                    hint: "+91 XXXXX XXXXX",
                    icon: Icons.phone_android_rounded,
                    validator: (v) => v!.length < 10 ? "Invalid phone number" : null,
                  ),

                  const SizedBox(height: 20),

                  // --- Field 4: Password ---
                  _buildSignupField(
                    label: "PASSWORD",
                    controller: _passwordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    validator: (v) => v!.length < 6 ? "Password too short" : null,
                  ),

                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  _buildSubmitButton(),
                  
                  const SizedBox(height: 25),
                  
                  // Back to Login
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "ALREADY A MEMBER? ",
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6C6C80), letterSpacing: 1),
                        children: const [
                          TextSpan(
                            text: "SIGN IN",
                            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        color: const Color(0xFF16213E).withOpacity(0.5),
      ),
      child: SvgPicture.asset('assets/logo.svg', width: 28, height: 28),
    );
  }

  Widget _buildSignupField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && !(isPasswordVisible ?? false),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withOpacity(0.6), size: 18),
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
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
        child: const Text("CREATE MEMBERSHIP", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      ),
    );
  }
}