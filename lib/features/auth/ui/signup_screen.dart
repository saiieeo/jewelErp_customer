import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_dashboard.dart';
import '../data/auth_service.dart';

import '../../../core/utils/luxury_toast.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false; 
  
  // Store Data Variables
  List<Map<String, dynamic>> _stores = [];
  bool _isLoadingStores = true;
  int? _selectedStoreId;

  // Essential Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  // Fetch the stores from AWS when the screen loads
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Ensure a store is selected
    if (_selectedStoreId == null) {
      // 🚨 NATIVE LUXURY TOAST: Missing Store Error
      LuxuryToast.show(
        context: context,
        title: "SELECTION REQUIRED",
        message: "Please select your preferred boutique to join.",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> nameParts = _nameController.text.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User'; 

      await AuthService().registerCustomer(
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        storeId: _selectedStoreId!, 
      );

      if (!mounted) return;
      
      // 🚨 NATIVE LUXURY TOAST: Success!
      LuxuryToast.show(
        context: context,
        title: "WELCOME TO JEWELFLOW",
        message: "Your elite membership has been created successfully.",
        isSuccess: true,
      );

      // Premium Pause: Let the user see the success animation for 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      
      // Navigate directly into the app
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
        title: "REGISTRATION FAILED",
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

                  // Field 1: Full Name
                  _buildSignupField(
                    label: "FULL NAME",
                    controller: _nameController,
                    hint: "Enter your name",
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v!.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  // Field 2: Email Address
                  _buildSignupField(
                    label: "EMAIL ADDRESS",
                    controller: _emailController,
                    hint: "name@luxury.com",
                    icon: Icons.email_outlined,
                    validator: (v) => (v == null || !v.contains('@')) ? "Invalid email" : null,
                  ),
                  const SizedBox(height: 20),

                  // Field 3: Phone Number
                  _buildSignupField(
                    label: "PHONE NUMBER",
                    controller: _phoneController,
                    hint: "+91 XXXXX XXXXX",
                    icon: Icons.phone_android_rounded,
                    validator: (v) => v!.length < 10 ? "Invalid phone number" : null,
                  ),
                  const SizedBox(height: 20),

                  // Field 4: Password
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

                  _buildStoreDropdown(),
                  
                  const SizedBox(height: 20),

                  // Submit Button
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

  Widget _buildStoreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PREFERRED BOUTIQUE",
          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        _isLoadingStores 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : DropdownButtonFormField<int>(
              initialValue: _selectedStoreId,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
              dropdownColor: const Color(0xFF1A1A2E), // Dark theme for dropdown menu
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
              hint: Text("Select your local store", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
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
              validator: (value) => value == null ? "Please select a store" : null,
            ),
      ],
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        color: const Color(0xFF16213E).withValues(alpha: 0.5),
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
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withValues(alpha: 0.6), size: 18),
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          disabledBackgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Color(0xFF0F0F1A), strokeWidth: 2.5),
              )
            : const Text(
                "CREATE MEMBERSHIP", 
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF0F0F1A))
              ),
      ),
    );
  }
}