import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW: For the phone dialer
import '../data/profile_service.dart';
import 'my_enquiries_screen.dart'; 
import '../../auth/ui/login_screen.dart'; 
import '../../auth/data/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService().getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NEW: Phone Dialer Logic ---
  Future<void> _callStore() async {
    // TODO: Replace with your actual store phone number
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919876543210'); 
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open phone dialer."), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = _profileData?['firstName'] ?? "Valued";
    final String lastName = _profileData?['lastName'] ?? "Customer";
    final String phone = _profileData?['phone'] ?? "No Phone Linked";
    final String email = _profileData?['email'] ?? "No Email Linked";
    final String city = _profileData?['city'] ?? "Add your address";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 100.0,
                floating: true,
                backgroundColor: const Color(0xFF0F0F1A),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    "Hello, $firstName", // Personalized Greeting UX
                    style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)
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
                      
                      // --- 1. Digital Membership Card ---
                      _buildMembershipCard(firstName, lastName, phone),

                      const SizedBox(height: 36),

                      // --- 2. Grouped Section: Activity ---
                      _buildSectionHeader("ACTIVITY"),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: "My Enquiries",
                            subtitle: "View history of your product questions",
                            showDivider: false, // Last item in the card has no divider
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyEnquiriesScreen()),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- 3. Grouped Section: Account Settings ---
                      _buildSectionHeader("ACCOUNT SETTINGS"),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.person_outline,
                            title: "Personal Information",
                            subtitle: email,
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: "Saved Addresses",
                            subtitle: city,
                            showDivider: false,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- 4. Grouped Section: Support ---
                      _buildSectionHeader("SUPPORT"),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.support_agent_rounded,
                            title: "Contact Store",
                            subtitle: "Speak directly with our jewelry experts",
                            showDivider: false,
                            onTap: _callStore, // Triggers the phone dialer!
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // --- 5. Logout Button (Production Style) ---
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _showLogoutDialog(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent.withAlpha((0.1 * 255).round()),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            "SIGN OUT", 
                            style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Padding for Bottom Nav
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // --- UI Helpers ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  // NEW UX: Groups related settings into one visually cohesive card
  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap, bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ),
          title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 12)) : null,
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6C6C80), size: 14),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 64, right: 20), // Aligns divider with text, skipping the icon
            child: Container(height: 1, color: Colors.white.withAlpha((0.05 * 255).round())),
          )
      ],
    );
  }

  Widget _buildMembershipCard(String fName, String lName, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16213E), Color(0xFF0F0F1A)],
        ),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "ELITE MEMBER",
                    style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 16),
                Text("$fName $lName", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(phone, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, size: 60, color: Color(0xFF0F0F1A)), // Dark QR on white background pops better
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Sign Out", style: GoogleFonts.playfairDisplay(color: Colors.white)),
        content: Text("Are you sure you want to sign out?", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("CANCEL", style: GoogleFonts.inter(color: Colors.white))
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logoutCustomer(); 
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("SIGN OUT", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}