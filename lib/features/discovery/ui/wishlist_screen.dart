import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/product_detail_screen.dart';
import '../data/discovery_service.dart';

// 🚨 IMPORTANT: Make sure this path is correct for where you saved the popup file!
import '../../../core/utils/cart_popup.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlistData();
  }

  // --- Fetch Data from AWS ---
  Future<void> _fetchWishlistData() async {
    try {
      final items = await DiscoveryService().getWishlist();
      if (mounted) {
        setState(() {
          _wishlistItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load wishlist: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- Remove Item API Call (UPDATED to accept itemName) ---
  Future<void> _removeItem(String id, String itemName) async {
    // Optimistic UI update for smooth animation
    setState(() {
      _wishlistItems.removeWhere((item) => item['id'].toString() == id);
    });

    try {
      await DiscoveryService().removeFromWishlist(id);
      
      if (mounted) {
        // 🚨 FIRE THE SLEEK POPUP INSTEAD OF THE SNACKBAR
        CartPopup.show(
          context: context, 
          isAdded: false, // Forces the grey "Removed" UI
          itemName: itemName,
        );
      }
    } catch (e) {
      // Revert if API fails
      _fetchWishlistData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove item"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "MY WISHLIST",
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _wishlistItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFFD4AF37),
                  backgroundColor: const Color(0xFF16213E),
                  onRefresh: _fetchWishlistData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _wishlistItems.length,
                    itemBuilder: (context, index) {
                      return _buildWishlistItem(_wishlistItems[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: const Color(0xFF16213E).withAlpha((0.8 * 255).round())),
          const SizedBox(height: 20),
          Text(
            "Your wishlist is empty",
            style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Save your favorite designs here for later.",
            style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    final String id = item['id']?.toString() ?? '';
    final String name = item['name']?.toString() ?? 'Unnamed Jewelry';
    final String purity = item['purity']?.toString() ?? '22K';
    
    final double weightVal = double.tryParse(item['netWeight']?.toString() ?? item['grossWeight']?.toString() ?? '0.0') ?? 0.0;
    final String weight = "${weightVal.toStringAsFixed(2)}g";
    
    final double metalRate = double.tryParse(item['metalRate']?.toString() ?? '0.0') ?? 0.0;
    final double makingCharges = double.tryParse(item['makingCharges']?.toString() ?? '0.0') ?? 0.0;
    final double stoneCharges = double.tryParse(item['stoneCharges']?.toString() ?? '0.0') ?? 0.0;
    
    final double calculatedPrice = (weightVal * metalRate) + makingCharges + stoneCharges;
    final String price = calculatedPrice > 0 
        ? "₹ ${calculatedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
        : "Price on Request";

    return Dismissible(
      key: Key(id.isNotEmpty ? id : UniqueKey().toString()),
      direction: DismissDirection.endToStart, // Swipe from Right to Left
      onDismissed: (direction) {
        if (id.isNotEmpty) {
          // 🚨 Pass the name into the remove function!
          _removeItem(id, name); 
        }
      },
      // The background that reveals itself when you swipe
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha((0.15 * 255).round()), // Deep premium red glow
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withAlpha((0.3 * 255).round())),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
      ),
      child: GestureDetector(
        onTap: () {
          if (id.isEmpty) return;
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: item,
              isWishlisted: true, 
              onToggleWishlist: () {
                _fetchWishlistData(); 
              },
            ),
          ));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withAlpha((0.4 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round())),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 30),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text("$purity • $weight", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11)),
                      const SizedBox(height: 8),
                      Text(price, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () {
                  if (id.isNotEmpty) {
                    // 🚨 Pass the name here too!
                    _removeItem(id, name); 
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}