import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Local state to track the wishlist status instantly
  late bool _isWishlistedLocal;

  @override
  void initState() {
    super.initState();
    // Set the initial state based on what the Dashboard passed us
    _isWishlistedLocal = widget.isWishlisted;
  }

  void _handleWishlistClick() {
    // 1. Update the UI on this screen instantly
    setState(() {
      _isWishlistedLocal = !_isWishlistedLocal;
    });
    // 2. Tell the Dashboard to actually add/remove it from the main list
    widget.onToggleWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          // --- 1. Product Image App Bar ---
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlistedLocal ? Icons.favorite : Icons.favorite_border,
                  color: _isWishlistedLocal ? Colors.redAccent : const Color(0xFFD4AF37),
                ),
                onPressed: _handleWishlistClick,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF16213E), Color(0xFF0F0F1A)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.diamond_outlined, size: 120, color: Color(0xFFD4AF37)),
                ),
              ),
            ),
          ),

          // --- 2. Product Details ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    ),
                    child: Text(
                      "100% HALLMARKED", 
                      style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product['name'],
                    style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['price'],
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 24),

                  // Specs Row
                  Row(
                    children: [
                      _buildSpecChip(Icons.monitor_weight_outlined, "Weight", widget.product['weight']),
                      const SizedBox(width: 16),
                      _buildSpecChip(Icons.verified_outlined, "Purity", widget.product['purity']),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  Text("DESCRIPTION", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(
                    widget.product['description'],
                    style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // --- 3. Bottom Action Bar ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleWishlistClick,
                icon: Icon(
                  _isWishlistedLocal ? Icons.favorite : Icons.favorite_border, 
                  color: _isWishlistedLocal ? Colors.redAccent : const Color(0xFFD4AF37), 
                  size: 20
                ),
                label: Text(
                  _isWishlistedLocal ? "SAVED" : "WISHLIST", 
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Enquire about ${widget.product['name']}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "ENQUIRE NOW", 
                  style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 10)),
                Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}