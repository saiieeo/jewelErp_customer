import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewel_app/features/discovery/ui/product_detail_screen.dart';
import 'package:jewel_app/features/discovery/ui/wishlist_screen.dart';
import 'package:jewel_app/features/old_gold/ui/old_gold_screen.dart';
import 'package:jewel_app/features/profile/ui/profile_screen.dart';
import 'package:jewel_app/features/vault/ui/vault_screen.dart';

class ShopDashboard extends StatefulWidget {
  final String shopName;
  
  const ShopDashboard({super.key, required this.shopName});

  @override
  State<ShopDashboard> createState() => _ShopDashboardState();
}

class _ShopDashboardState extends State<ShopDashboard> {
  int _currentIndex = 0;
  bool _showLiveStock = true; // Toggle between Live Stock and Custom Design

  List<Map<String, dynamic>> _wishlist = [];

  // 1. Live Stock Data
  final List<Map<String, dynamic>> _liveProducts = [
    {
      'id': 'L1',
      'name': 'Bridal Gold Necklace',
      'price': '₹ 3,45,000',
      'weight': '45.5g',
      'purity': '22K',
      'description': 'An exquisite handcrafted 22K gold bridal necklace featuring intricate temple motifs.',
    },
    {
      'id': 'L2',
      'name': 'Diamond Solitaire Ring',
      'price': '₹ 1,12,000',
      'weight': '4.2g',
      'purity': '18K',
      'description': 'A stunning 1-carat VVS diamond set in an 18K white gold band.',
    },
    {
      'id': 'L3',
      'name': 'Antique Gold Bangles',
      'price': '₹ 2,15,000',
      'weight': '28.0g',
      'purity': '22K',
      'description': 'Set of two antique-finish gold bangles with intricate filigree work.',
    },
  ];

  // 2. Custom Design Templates
  final List<Map<String, dynamic>> _customProducts = [
    {
      'id': 'C1',
      'name': 'Bespoke Name Pendant',
      'price': 'Custom Quote',
      'weight': 'Approx 5-8g',
      'purity': '18K / 22K',
      'description': 'Personalized gold pendant crafted with your name or initials in elegant typography.',
    },
    {
      'id': 'C2',
      'name': 'Heritage Choker Design',
      'price': 'Custom Quote',
      'weight': 'Based on requirement',
      'purity': '22K',
      'description': 'Bring your heirloom designs to life. Upload a sketch and we will craft it.',
    },
  ];

  void _toggleWishlist(Map<String, dynamic> product) {
    setState(() {
      final exists = _wishlist.any((item) => item['id'] == product['id']);
      if (exists) {
        _wishlist.removeWhere((item) => item['id'] == product['id']);
      } else {
        _wishlist.add(product);
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the hardware back button / swipe back gesture
    return PopScope(
      // canPop decides if the app should actually go back to the previous screen.
      // We only allow it to go back to the Mall if we are ALREADY on the Home tab (index 0).
      canPop: _currentIndex == 0, 
      onPopInvoked: (didPop) {
        // If didPop is true, it means we were on index 0 and it already went back to the Mall.
        if (didPop) return;

        // If didPop is false, it means we intercepted it. Let's switch to the Home tab!
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: SafeArea(
          child: _currentIndex == 0 ? _buildHomeContent() 
            : _currentIndex == 1 ? WishlistScreen(
                wishlistItems: _wishlist, 
                onRemove: _toggleWishlist,
              )
            : _currentIndex == 2 ? const VaultScreen() 
            : _currentIndex == 3 ? const OldGoldScreen() 
            : _currentIndex == 4 ? const ProfileScreen() 
            : _buildPlaceholderScreen(),
        ),
        
        // --- PREMIUM BOTTOM NAVIGATION BAR ---
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.1))),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: const Color(0xFF16213E),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: const Color(0xFFA0A0B8),
            selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, height: 1.5),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, height: 1.5),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: "Wishlist"),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Vault"),
              BottomNavigationBarItem(icon: Icon(Icons.recycling_outlined), activeIcon: Icon(Icons.recycling), label: "Old Gold"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
  // --- MAIN HOME DASHBOARD ---
  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // 1. Shop Header (Name & Location)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shopName.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Color(0xFFD4AF37)),
                            const SizedBox(width: 4),
                            Text("Satara, India", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFFD4AF37)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search rings, necklaces, designs...",
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF6C6C80)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFA0A0B8)),
                    suffixIcon: const Icon(Icons.tune, color: Color(0xFFD4AF37)), // Filter icon
                    filled: true,
                    fillColor: const Color(0xFF16213E).withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),

              // 3. Live Gold Rate Ticker (UX Addition)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text("LIVE 24K RATE: ", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 10, fontWeight: FontWeight.bold)),
                    Text("₹ 7,450 / gm", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 4. Quick Highlights (Special Offers / Arrivals)
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildPromoBanner("Diwali Special", "Up to 20% off on making charges", Colors.deepPurple.withOpacity(0.5)),
                    const SizedBox(width: 15),
                    _buildPromoBanner("New Arrivals", "Explore the Royal Antique Collection", const Color(0xFF16213E)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 5. Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("CATEGORIES", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryItem("Rings", Icons.radio_button_unchecked),
                    _buildCategoryItem("Necklaces", Icons.waves),
                    _buildCategoryItem("Bangles", Icons.motion_photos_auto),
                    _buildCategoryItem("Earrings", Icons.wb_twilight),
                    _buildCategoryItem("Coins", Icons.monetization_on_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 6. Catalog Toggle (Live Stock vs Custom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton("LIVE STOCK", true)),
                      Expanded(child: _buildTabButton("CUSTOM DESIGN", false)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 7. Catalog Grid View
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Dynamically pick the right list based on the toggle!
                final currentList = _showLiveStock ? _liveProducts : _customProducts;
                return _buildProductCard(currentList[index]);
              },
              // Set the count exactly to the length of the chosen list to stop ghosting
              childCount: _showLiveStock ? _liveProducts.length : _customProducts.length, 
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildPromoBanner(String title, String subtitle, Color bgColor) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        image: const DecorationImage(
          image: AssetImage('assets/banner_bg.png'), // Optional: Add a faint pattern image later
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)),
            child: Text("OFFER", style: GoogleFonts.inter(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF16213E),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isLiveStockTab) {
    bool isSelected = _showLiveStock == isLiveStockTab;
    return GestureDetector(
      onTap: () => setState(() => _showLiveStock = isLiveStockTab),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFF0F0F1A) : const Color(0xFFA0A0B8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildProductCard(Map<String, dynamic> product) {
    final isWishlisted = _wishlist.any((item) => item['id'] == product['id']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              isWishlisted: isWishlisted,
              onToggleWishlist: () {
                _toggleWishlist(product);
                setState(() {}); // Refresh Dashboard so heart icon updates
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(
                  _showLiveStock ? Icons.diamond_outlined : Icons.draw_outlined, 
                  size: 40, 
                  color: const Color(0xFFD4AF37)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product['purity']} • ${product['weight']}",
                    style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'],
                        style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () => _toggleWishlist(product),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border, 
                          color: isWishlisted ? Colors.redAccent : const Color(0xFFA0A0B8), 
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } 
  // Placeholder for when you click other tabs in Bottom Nav
  Widget _buildPlaceholderScreen() {
    return Center(
      child: Text(
        "Screen Index: $_currentIndex\n(Coming Soon)",
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 16),
      ),
    );
  }
}