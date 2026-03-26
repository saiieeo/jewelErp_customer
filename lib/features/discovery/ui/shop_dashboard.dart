import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/discovery_service.dart';
import 'package:jewel_app/features/discovery/ui/product_detail_screen.dart';
import 'package:jewel_app/features/discovery/ui/wishlist_screen.dart';
import 'package:jewel_app/features/profile/ui/profile_screen.dart';
import 'package:jewel_app/features/vault/ui/vault_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jewel_app/features/schemes/ui/scheme_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/cart_popup.dart';

class ShopDashboard extends StatefulWidget {
  
  const ShopDashboard({super.key});

  @override
  State<ShopDashboard> createState() => _ShopDashboardState();
}

class _ShopDashboardState extends State<ShopDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showLiveStock = true; 
  bool _isLoading = true;

  // Personalization & Storage
  final _storage = const FlutterSecureStorage();
  String _customerName = "Guest";
  String _storeName = "Loading...";

  // Data Lists
  final List<Map<String, dynamic>> _wishlist = [];
  List<Map<String, dynamic>> _liveProducts = [];

  // Ticker Animation Variables
  late AnimationController _pulseController;
  Timer? _rateTimer;
  int _currentRateIndex = 0;
  Map<String, String> _liveRates = {"24K": "...", "22K": "...", "18K": "..."};

  File? _customDesignImage;
  final TextEditingController _customDesignDescController = TextEditingController();
  bool _isSubmittingDesign = false;

  String _selectedCategory = "";

final TextEditingController _searchController = TextEditingController();
List<Map<String, dynamic>> _filteredProducts = [];

  Future<void> _pickCustomDesignImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _customDesignImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitCustomDesignRequest() async {
    final description = _customDesignDescController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a description"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isSubmittingDesign = true);

    try {
      String? imageUrl;
      if (_customDesignImage != null) {
        imageUrl = await DiscoveryService().uploadEnquiryImage(_customDesignImage!);
      }

      await DiscoveryService().submitEnquiry(
        jewelryItemId: null, 
        subject: "Bespoke Custom Design Request",
        message: description,
        imageUrl: imageUrl,
      );

      if (mounted) {
        setState(() {
          _customDesignImage = null;
          _customDesignDescController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Design request sent to our artisans!"), backgroundColor: Color(0xFFD4AF37)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit request: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSubmittingDesign = false);
    }
  }

 void _runFilter(String enteredKeyword) {
  List<Map<String, dynamic>> results = [];
  if (enteredKeyword.isEmpty) {
    results = _liveProducts;
  } else {
    results = _liveProducts.where((product) {
      final name = product["name"]?.toString().toLowerCase() ?? "";
      final purity = product["purity"]?.toString().toLowerCase() ?? "";
      final sku = product["sku"]?.toString().toLowerCase() ?? "";
      final searchKey = enteredKeyword.toLowerCase();

      return name.contains(searchKey) || 
             purity.contains(searchKey) || 
             sku.contains(searchKey);
    }).toList();
  }

  setState(() {
    _filteredProducts = results;
  });
}

void _filterByCategory(String category) {
  _searchController.clear();

  setState(() {
    // Toggle logic: If clicking the same one, reset to all. Otherwise, select new one.
    if (_selectedCategory == category) {
      _selectedCategory = "";
      _filteredProducts = _liveProducts;
    } else {
      _selectedCategory = category;
      _showLiveStock = true;
      
      String searchKey = category.toLowerCase();
      if (searchKey.endsWith('s')) {
        searchKey = searchKey.substring(0, searchKey.length - 1);
      }
      
      _filteredProducts = _liveProducts.where((product) {
        final name = product["name"]?.toString().toLowerCase() ?? "";
        return name.contains(searchKey);
      }).toList();
    }
  });
}
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _loadDashboardData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final name = await _storage.read(key: 'customer_name');
    final sName = await _storage.read(key: 'store_name');
    final sId = await _storage.read(key: 'store_id') ?? '1';
    
    if (mounted) {
      setState(() {
        _customerName = name ?? "Valued Member";
        _storeName = sName ?? "Boutique";
      });
    }

    try {
      final rates = await DiscoveryService().getLiveRates();
      final catalog = await DiscoveryService().getLiveCatalog(sId); 
      final cloudWishlist = await DiscoveryService().getWishlist(); 
      
      if (mounted) {
        setState(() {
          _liveRates = rates;
          _liveProducts = catalog;
          _filteredProducts = catalog;
          _wishlist.clear();
          _wishlist.addAll(cloudWishlist); 
          
          _isLoading = false;
        });

        _rateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) setState(() => _currentRateIndex = (_currentRateIndex + 1) % _liveRates.length);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not load data: $e"), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product) async {
    final String id = product['id']?.toString() ?? '';
    if (id.isEmpty) return;

    final String itemName = product['name']?.toString() ?? 'Jewelry Item';

    final bool isCurrentlyWishlisted = _wishlist.any((item) => item['id'].toString() == id);

    setState(() {
      if (isCurrentlyWishlisted) {
        _wishlist.removeWhere((item) => item['id'].toString() == id);
      } else {
        _wishlist.add(product);
      }
    });

    try {
      if (isCurrentlyWishlisted) {
        await DiscoveryService().removeFromWishlist(id);
        if (mounted) {
          CartPopup.show(context: context, isAdded: false, itemName: itemName);
        }
      } else {
        await DiscoveryService().addToWishlist(id);
        if (mounted) {
          CartPopup.show(context: context, isAdded: true, itemName: itemName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isCurrentlyWishlisted) {
            _wishlist.add(product);
          } else {
            _wishlist.removeWhere((item) => item['id'].toString() == id);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error: Could not sync wishlist"), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: SafeArea(
          child: _currentIndex == 0 ? _buildHomeContent() 
            : _currentIndex == 1 ? const VaultScreen()            
            : _currentIndex == 2 ? const WishlistScreen() 
            : _currentIndex == 3 ? const SchemeScreen() 
            : _currentIndex == 4 ? const ProfileScreen() 
            : _buildPlaceholderScreen(),
        ),
        
        // --- BOTTOM NAVIGATION BAR ---
        bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          border: Border(top: BorderSide(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()))),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withAlpha((0.3 * 255).round())),
          ]
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: GNav(
              rippleColor: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round()),
              hoverColor: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
              gap: 8,
              activeColor: const Color(0xFF0F0F1A), 
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: const Color(0xFFD4AF37), 
              color: const Color(0xFFA0A0B8), 
              textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F1A)),
              selectedIndex: _currentIndex,
              onTabChange: (index) async {
                setState(() => _currentIndex = index);
                if (index == 0) {
                  try {
                    final updatedWishlist = await DiscoveryService().getWishlist();
                    if (mounted) {
                      setState(() {
                        _wishlist.clear();
                        _wishlist.addAll(updatedWishlist);
                      });
                    }
                  } catch (e) {
                    debugPrint("Background sync failed: $e");
                  }
                }
              },
              tabs: const [
                GButton(icon: Icons.storefront_outlined, text: 'Home'),
                GButton(icon: Icons.account_balance_wallet_outlined, text: 'Vault'),
                GButton(icon: Icons.favorite_border, text: 'Wishlist'),
                GButton(icon: Icons.recycling_outlined, text: 'Schemes'),
                GButton(icon: Icons.person_outline, text: 'Profile'),
              ],
            ),
          ),
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
              
              // 1. Dynamic Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $_customerName",
                          style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _storeName.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFFD4AF37)), onPressed: () {}),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search rings, necklaces, designs...",
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF6C6C80)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFA0A0B8)),
                   suffixIcon: _searchController.text.isNotEmpty 
        ? IconButton(
            icon: const Icon(Icons.clear, color: Color(0xFFD4AF37)),
            onPressed: () {
              _searchController.clear();
              _runFilter('');
            },
          )
        : const Icon(Icons.tune, color: Color(0xFFD4AF37)),
                    filled: true,
                    fillColor: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),

              // 3. UPDATED: Bigger & Clickable Live Gold Rate Ticker
              _buildAnimatedGoldRateTicker(),

              const SizedBox(height: 25),

              // 4. Promotions & Categories
              _buildSchemeBanner(),
              const SizedBox(height: 30),
             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes "Categories" to left and "See All" to right
    children: [
      Text(
        "CATEGORIES", 
        style: GoogleFonts.inter(
          color: const Color(0xFFD4AF37), 
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.5
        )
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = "";
            _filteredProducts = _liveProducts;
            _searchController.clear(); // Clean up the search bar too
          });
        },
        child: Text(
          "SEE ALL", 
          style: GoogleFonts.inter(
            color: const Color(0xFFA0A0B8), 
            fontSize: 10, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          )
        ),
      ),
    ],
  ),
),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryItem("Rings", Icons.radio_button_unchecked),
                    _buildCategoryItem("Necklaces", Icons.waves),
                    _buildCategoryItem("Earrings", Icons.diamond_outlined),
                    _buildCategoryItem("Bangles", Icons.motion_photos_auto),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 5. Catalog Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
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

        // 6. UPDATED: Dynamic View (Grid for Live Stock, Form for Custom Design)
        _isLoading 
          ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
              ),
            )
          : _showLiveStock 
            ? (_filteredProducts.isEmpty 
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: Column(
                        children: [
                         Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16213E).withValues(alpha: 0.5),
                  ),
                  child: Icon(
                    Icons.search_off_rounded, 
                    size: 40, 
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5)
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "NO TREASURES FOUND",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We couldn't find anything matching '${_searchController.text}'.\nTry searching for 'Ring' or 'Gold'.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA0A0B8), 
                    fontSize: 13,
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 24),
                // "Clear Search" button to help the user get back
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _runFilter('');
                  },
                  child: Text(
                    "CLEAR SEARCH",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
                )
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnimatedProductCard(_filteredProducts[index], index),
                      childCount: _filteredProducts.length, 
                    ),
                  ),
                ))
            : SliverToBoxAdapter(
                // Replaces the grid with the Bespoke Design form!
                child: _buildCustomDesignForm(),
              ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // --- NEW: ANIMATED WIDGETS ---

 // --- UPDATED: Responsive Gold Rate Ticker ---
  Widget _buildAnimatedGoldRateTicker() {
    final currentKey = _liveRates.keys.elementAt(_currentRateIndex);
    final currentValue = _liveRates.values.elementAt(_currentRateIndex);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
      child: GestureDetector(
        onTap: () => _showLiveRatesBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Slightly reduced padding for smaller phones
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
            boxShadow: [
              BoxShadow(color: const Color(0xFFD4AF37).withAlpha((0.05 * 255).round()), blurRadius: 10, spreadRadius: 1),
            ]
          ),
          child: Row(
            children: [
              // 1. The Glowing Dot
              FadeTransition(
                opacity: _pulseController,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent, 
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 8)],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // 2. The Label (Wrapped in Expanded so it shrinks on small screens!)
              Expanded(
                child: Text(
                  "LIVE MARKET", 
                  style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Adds "..." if it runs out of space
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 3. The Animated Value
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  "$currentKey : $currentValue",
                  key: ValueKey<int>(_currentRateIndex),
                  // Slightly reduced font size so it fits better
                  style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProductCard(Map<String, dynamic> product, int index) {
    final delay = index * 100;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Interval(delay > 1000 ? 0 : delay / 2000, 1.0, curve: Curves.easeOutCubic),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildProductCard(product), 
    );
  }

  // --- NEW: Custom Design Inline Form ---
 Widget _buildCustomDesignForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create Your Masterpiece", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Upload a reference image and describe your dream jewelry. Our artisans will bring it to life.", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            
            // --- Image Upload Box ---
            GestureDetector(
              onTap: _pickCustomDesignImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _customDesignImage != null ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()), 
                    style: BorderStyle.solid
                  ),
                  image: _customDesignImage != null 
                    ? DecorationImage(image: FileImage(_customDesignImage!), fit: BoxFit.cover)
                    : null,
                ),
                child: _customDesignImage == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFD4AF37), size: 48),
                        const SizedBox(height: 12),
                        Text("Tap to upload reference image", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                      ],
                    )
                  : Stack(
                      children: [
                        // A subtle gradient so the "Change Image" text is readable over bright photos
                        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black.withAlpha((0.4 * 255).round()))),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit, color: Colors.white, size: 24),
                              const SizedBox(height: 4),
                              Text("Tap to change image", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- Description Box ---
            TextField(
              controller: _customDesignDescController,
              maxLines: 4,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Describe your requirements (Metal, weight, stones)",
                alignLabelWithHint: true,
                labelStyle: GoogleFonts.inter(color: const Color(0xFF6C6C80)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmittingDesign ? null : _submitCustomDesignRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: const Color(0xFFD4AF37).withAlpha((0.5 * 255).round()),
                ),
                child: _isSubmittingDesign 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF0F0F1A), strokeWidth: 2))
                  : Text("SUBMIT REQUEST", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- NEW: Live Rates Bottom Sheet ---
 void _showLiveRatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // Taller for the premium graph feel
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 2)), 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF6C6C80), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("LIVE MARKET", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text("Today's Gold Rates", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.greenAccent.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                        const SizedBox(width: 6),
                        Text("MARKET OPEN", style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: DiscoveryService().getTodayRates(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("API Failed:\n${snapshot.error}", style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center));
                    }

                    final rates = snapshot.data ?? {};
                    final rate24K = double.tryParse(rates['24K']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 7450.0;
                    final rate22K = double.tryParse(rates['22K']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 6830.0;
                    final rate18K = double.tryParse(rates['18K']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 5587.0;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // --- 1. The Hero Graph Card (24K) ---
                        _buildHeroGraphCard("24K PURE GOLD", "99.9% Purity", rate24K),
                        
                        const SizedBox(height: 24),
                        Text("STANDARD PURITIES", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 16),

                        // --- 2. Secondary Rates (22K and 18K side-by-side) ---
                        Row(
                          children: [
                            Expanded(child: _buildSecondaryRateCard("22K GOLD", "91.6% (Standard)", rate22K)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildSecondaryRateCard("18K GOLD", "75.0% Purity", rate18K)),
                          ],
                        ),

                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFFA0A0B8), size: 16),
                              const SizedBox(width: 12),
                              Expanded(child: Text("Rates are exclusive of GST and making charges. Prices update every 5 minutes.", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11, height: 1.4))),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  // --- The Premium Hero Graph Card ---
  Widget _buildHeroGraphCard(String title, String subtitle, double rate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16213E), Color(0xFF0F0F1A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.4 * 255).round())),
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const Icon(Icons.show_chart, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: rate - 1500, end: rate),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text("₹ ${value.toStringAsFixed(0)} / 10g", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold));
            },
          ),
          Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
          
          const SizedBox(height: 30),
          
          // The Custom Sparkline Graph
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(), // The magic graph painter!
            ),
          ),
        ],
      ),
    );
  }

  // --- The Secondary Small Cards ---
  Widget _buildSecondaryRateCard(String title, String subtitle, double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: rate - 800, end: rate),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text("₹${value.toStringAsFixed(0)}", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 10)),
        ],
      ),
    );
  }


  // --- HELPER WIDGETS ---
  Widget _buildProductCard(Map<String, dynamic> product) {
    final String id = product['id']?.toString() ?? UniqueKey().toString(); 
    final String name = product['name']?.toString() ?? 'Unnamed Jewelry';
    final String purity = product['purity']?.toString() ?? '22K';

    final double weightVal = (product['netWeight'] ?? product['grossWeight'] ?? 0.0).toDouble();
    final String weight = "${weightVal.toStringAsFixed(2)}g";

    final double metalRate = (product['metalRate'] ?? 0.0).toDouble();
    final double makingCharges = (product['makingCharges'] ?? 0.0).toDouble();
    final double stoneCharges = (product['stoneCharges'] ?? 0.0).toDouble();

    final double calculatedPrice = (weightVal * metalRate) + makingCharges + stoneCharges;

    final String price = calculatedPrice > 0 
        ? "₹ ${calculatedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
        : "Price on Request";

    final isWishlisted = _wishlist.any((item) => item['id'].toString() == id);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            product: product, 
            isWishlisted: isWishlisted,
            onToggleWishlist: () {
              _toggleWishlist(product);
              setState(() {}); 
            },
          ),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.1)),
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
                child: Icon(_showLiveStock ? Icons.diamond_outlined : Icons.draw_outlined, size: 40, color: const Color(0xFFD4AF37)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("$purity • $weight", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                      GestureDetector(
                        onTap: () => _toggleWishlist(product),
                        child: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, color: isWishlisted ? Colors.redAccent : const Color(0xFFA0A0B8), size: 18),
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

  Widget _buildSchemeBanner() {
    return GestureDetector(
      onTap: () {
       setState(() {
         _currentIndex = 3;
       });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 140, // Fixed height makes it look like a standard ad banner
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // A striking, premium solid gold gradient
            colors: [Color(0xFFE5C058), Color(0xFFB38D22)], 
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round()), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background diamond to make it look like an ad
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.diamond_outlined, size: 120, color: Colors.white.withAlpha((0.15 * 255).round())),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SMART WEALTH PLANS", 
                          style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start Your Gold\nJourney Today", 
                          style: GoogleFonts.playfairDisplay(color: const Color(0xFF0F0F1A), fontSize: 22, fontWeight: FontWeight.bold, height: 1.1)
                        ),
                      ],
                    ),
                  ),
                  // The distinct CTA (Call to Action) button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F1A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text("EXPLORE", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 Widget _buildCategoryItem(String title, IconData icon) {
  bool isSelected = _selectedCategory == title;
  return GestureDetector(
    onTap: () => _filterByCategory(title), // 🚨 Trigger the filter!
    child: Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: isSelected ? const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()) : const Color(0xFF16213E),
              border: Border.all(
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
           child: Icon(
              icon, 
              color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withAlpha((0.7 * 255).round()), 
              size: 24
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildTabButton(String title, bool isLiveStockTab) {
    bool isSelected = _showLiveStock == isLiveStockTab;
    return GestureDetector(
      onTap: () => setState(() => _showLiveStock = isLiveStockTab),
      child: Container(
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(title, style: GoogleFonts.inter(color: isSelected ? const Color(0xFF0F0F1A) : const Color(0xFFA0A0B8), fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Widget _buildPlaceholderScreen() {
    return Center(child: Text("Screen Index: $_currentIndex\n(Coming Soon)", textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 16)));
  }
}
// --- CUSTOM PAINTER FOR THE FINTECH GRAPH ---
class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent // Trend line color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Mocking a beautiful upward trend curve
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 1.0, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, 0);

    // Add a glowing shadow behind the line
    canvas.drawShadow(path, Colors.greenAccent, 4.0, false);
    
    // Draw the actual line
    canvas.drawPath(path, paint);

    // Draw the glowing dot at the end of the line (current price point)
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width, 0), 4.0, dotPaint);
    
    final glowPaint = Paint()
      ..color = Colors.greenAccent.withAlpha((0.5 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.width, 0), 8.0, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}