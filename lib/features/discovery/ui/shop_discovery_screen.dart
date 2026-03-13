import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/shop_dashboard.dart';

class ShopDiscoveryScreen extends StatelessWidget {
  const ShopDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar for a luxury feel
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "JEWELFLOW MALL",
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: const Color(0xFFD4AF37),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFFA0A0B8)),
            onPressed: () => debugPrint("Profile clicked"),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover Excellence",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Choose a boutique to explore their collection",
                  style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14),
                ),
              ],
            ),
          ),

          // Shop List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3, // Later this will be shopList.length from Java API
              itemBuilder: (context, index) {
                return _buildShopCard(
                  context,
                  name: index == 0 ? "Krishna Jewelers" : index == 1 ? "Satara Diamonds" : "Royal Gold",
                  location: "Main Street, Satara",
                  rating: "4.9",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, {required String name, required String location, required String rating}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        children: [
          // Shop Image Placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [const Color(0xFF1A1A2E), const Color(0xFFD4AF37).withAlpha((0.2 * 255).round())],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.store_mall_directory_outlined, size: 50, color: Color(0xFFD4AF37)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Visit Button
                ElevatedButton(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShopDashboard(shopName: name),
    ),
  );
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(100, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("VISIT", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}