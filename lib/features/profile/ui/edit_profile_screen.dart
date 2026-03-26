import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  final int initialTabIndex;
  const EditProfileScreen({super.key, this.initialTabIndex = 0});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "COMPLETE PROFILE",
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: const Color(0xFFD4AF37),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          indicatorWeight: 3,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: const Color(0xFFA0A0B8),
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "PERSONAL"),
            Tab(text: "ADDRESS"),
            Tab(text: "KYC DOCS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(),
          _buildAddressTab(),
          _buildKycTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          border: Border(top: BorderSide(color: Colors.white.withAlpha((0.05 * 255).round()))),
        ),
        child: ElevatedButton(
          onPressed: () {
            debugPrint("Saving Profile Data for Tab ${_tabController.index}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFFD4AF37),
                content: Text("Information Saved Successfully", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold)),
              )
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "SAVE & SECURE", 
            style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  // --- TAB 1: PERSONAL INFO ---
  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("BASIC DETAILS"),
          const SizedBox(height: 16),
          _buildInputField(label: "FIRST NAME", hint: "Saee", icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildInputField(label: "LAST NAME", hint: "Jambhale", icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildInputField(label: "DATE OF BIRTH", hint: "DD/MM/YYYY", icon: Icons.calendar_today_outlined, isReadOnly: true),
          
          const SizedBox(height: 30),
          _buildSectionHeader("CONTACT INFO"),
          const SizedBox(height: 16),
          _buildInputField(label: "EMAIL ADDRESS", hint: "example@email.com", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildInputField(label: "PHONE NUMBER", hint: "+91 9876543210", icon: Icons.phone_android_outlined),
        ],
      ),
    );
  }

  // --- TAB 2: ADDRESS ---
  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("DELIVERY & BILLING ADDRESS"),
          const SizedBox(height: 16),
          _buildInputField(label: "STREET ADDRESS / FLAT NO.", hint: "e.g. 402, Luxury Heights", icon: Icons.home_outlined),
          const SizedBox(height: 16),
          _buildInputField(label: "LANDMARK", hint: "e.g. Near City Center", icon: Icons.flag_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputField(label: "PINCODE", hint: "415001", icon: Icons.pin_drop_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildInputField(label: "CITY", hint: "Satara", icon: Icons.location_city_outlined)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(label: "STATE", hint: "Maharashtra", icon: Icons.map_outlined),
        ],
      ),
    );
  }

  // --- TAB 3: KYC & DOCUMENTS ---
  Widget _buildKycTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Govt. regulations require PAN for transactions above ₹2 Lakhs.",
                    style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          _buildSectionHeader("PERMANENT ACCOUNT NUMBER"),
          const SizedBox(height: 16),
          _buildInputField(label: "PAN NUMBER", hint: "ABCDE1234F", icon: Icons.credit_card_outlined),
          const SizedBox(height: 16),
          _buildUploadBox("Upload PAN Card Photo"),

          const SizedBox(height: 40),
          
          _buildSectionHeader("ADDRESS PROOF (AADHAR)"),
          const SizedBox(height: 16),
          _buildInputField(label: "AADHAR NUMBER", hint: "XXXX XXXX XXXX", icon: Icons.badge_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildUploadBox("Aadhar Front")),
              const SizedBox(width: 16),
              Expanded(child: _buildUploadBox("Aadhar Back")),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: const Color(0xFFD4AF37),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, required IconData icon, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6C6C80), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: isReadOnly,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withAlpha((0.5 * 255).round()), size: 18),
            fillColor: const Color(0xFF16213E).withAlpha((0.4 * 255).round()),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF16213E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String label) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        // A standard trick for a dashed-looking border in pure flutter without extra packages
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.4 * 255).round()), style: BorderStyle.solid), 
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: Color(0xFFD4AF37), size: 28),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}