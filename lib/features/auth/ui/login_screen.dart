import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_dashboard.dart';
import 'signup_screen.dart';
import '../data/auth_service.dart';

import '../../../core/utils/luxury_toast.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Store Data Variables
  List<Map<String, dynamic>> _stores = [];
  bool _isLoadingStores = true;
  int? _selectedStoreId;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    try {
      final stores = await AuthService().getStores();
      if (mounted) {
        setState(() {
          _stores = stores;
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStores = false);
        // 🚨 NATIVE LUXURY TOAST: Error fetching stores
        LuxuryToast.show(
          context: context,
          title: "CONNECTION ERROR",
          message: "Could not load boutiques. Please try again.",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStoreId == null) {
      // 🚨 NATIVE LUXURY TOAST: Missing Store Error
      LuxuryToast.show(
        context: context,
        title: "SELECTION REQUIRED",
        message: "Please select your boutique to continue.",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().loginCustomer(
        _phoneController.text.trim(),
        _passwordController.text,
        _selectedStoreId!, 
      );

      if (!mounted) return;
      
      // 🚨 NATIVE LUXURY TOAST: Success!
      LuxuryToast.show(
        context: context,
        title: "WELCOME BACK",
        message: "Successfully signed in to your vault.",
        isSuccess: true,
      );

      // Premium Pause: Let the user see the success animation for 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Navigate to Dashboard on Success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ShopDashboard()),
        (route) => false, 
      );
      
    } catch (e) {
      if (!mounted) return;
      // 🚨 NATIVE LUXURY TOAST: Auth Error
      LuxuryToast.show(
        context: context,
        title: "AUTHENTICATION FAILED",
        message: e.toString().replaceAll('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                  const SizedBox(height: 60),
                  
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
                  
                  const SizedBox(height: 50),

                  // --- Phone Number Field ---
                  _buildLoginField(
                    label: "PHONE NUMBER",
                    controller: _phoneController,
                    hint: "+91 XXXXX XXXXX",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length < 10) ? "Enter valid phone number" : null,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // --- Password Field ---
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

                   _buildStoreDropdown(),

                   const SizedBox(height: 20),
                  
                  _buildLoginButton(),
                  
                  const SizedBox(height: 40),
                  
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

  // --- UI Helpers ---

  Widget _buildStoreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT BOUTIQUE",
          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        _isLoadingStores 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : DropdownButtonFormField<int>(
              initialValue: _selectedStoreId,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
              dropdownColor: const Color(0xFF1A1A2E), 
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.storefront_outlined, color: const Color(0xFFD4AF37).withValues(alpha: 0.6), size: 18),
                fillColor: const Color(0xFF16213E).withValues(alpha: 0.4),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF16213E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
              hint: Text("Choose your local store", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              items: _stores.map((store) {
                return DropdownMenuItem<int>(
                  value: store['id'], 
                  child: Text(store['name']), 
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStoreId = value;
                });
              },
              validator: (value) => value == null ? "Required" : null,
            ),
      ],
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        color: const Color(0xFF16213E).withValues(alpha: 0.5),
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
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withValues(alpha: 0.7), size: 20),
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
            fillColor: const Color(0xFF16213E).withValues(alpha: 0.4),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF16213E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
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
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          disabledBackgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
        ),
        child: _isLoading 
            ? const SizedBox(
                height: 24, 
                width: 24, 
                child: CircularProgressIndicator(color: Color(0xFF0F0F1A), strokeWidth: 2.5)
              )
            : const Text(
                "ENTER THE VAULT",
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Color(0xFF0F0F1A)),
              ),
      ),
    );
  }
}