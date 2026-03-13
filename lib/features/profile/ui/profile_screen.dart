import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/profile/ui/edit_profile_screen.dart'; // Ensure this path is correct for your project

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          // --- 1. Premium Header ---
          SliverAppBar(
            expandedHeight: 100.0,
            floating: true,
            backgroundColor: const Color(0xFF0F0F1A),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Profile", 
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Color(0xFFD4AF37)),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // --- 2. Digital Membership Card (In-Store Scan) ---
                  _buildMembershipCard(),

                  const SizedBox(height: 30),

                  // --- 3. KYC Action Banner (High Priority) ---
                  _buildKYCSection(context), // Passed context for navigation

                  const SizedBox(height: 40),

                  // --- 4. Personal Information & Settings ---
                  Text(
                    "ACCOUNT SETTINGS",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: "Personal Information",
                    subtitle: "Name, Email, Phone",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen(initialTabIndex: 0)),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.location_on_outlined,
                    title: "Saved Addresses",
                    subtitle: "Manage delivery locations",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen(initialTabIndex: 1)),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.account_balance_outlined,
                    title: "Bank Details",
                    subtitle: "For scheme maturity payouts",
                    onTap: () {
                      // Navigate to bank details screen when created
                    },
                  ),
                  
                  const SizedBox(height: 30),

                  Text(
                    "PREFERENCES",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingsTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Notifications",
                    subtitle: "Offers, Rate drops, Reminders",
                  ),
                  _buildSettingsTile(
                    icon: Icons.support_agent_outlined,
                    title: "Help & Support",
                    subtitle: "Contact your boutique",
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // --- 5. Logout Button ---
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Logout logic
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      label: Text(
                        "SIGN OUT", 
                        style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Spacing for BottomNav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF16213E), const Color(0xFF1A1A2E).withAlpha((0.8 * 255).round())],
        ),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.5 * 255).round())),
                  ),
                  child: Text(
                    "ELITE MEMBER", 
                    style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "saee j", 
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text("+91 98765 43210", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
                const SizedBox(height: 16),
                Text("CUSTOMER ID", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 10, letterSpacing: 1.5)),
                Text("100245", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          ),
          
          // QR Code Container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2, // In production, replace with a real QR widget
              size: 80, 
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.4 * 255).round())),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_outlined, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("KYC Pending", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  "Required for purchases above ₹2 Lakhs.", 
                  style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen(initialTabIndex: 2)), 
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("COMPLETE", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // FIXED: Passed the onTap down to the ListTile
  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.4 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.02 * 255).round())),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        ),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6C6C80), size: 14),
        onTap: onTap, // Uses the passed callback instead of an empty function
      ),
    );
  }
}