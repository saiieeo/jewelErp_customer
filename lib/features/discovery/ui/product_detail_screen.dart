import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/discovery_service.dart';

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

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late bool _isWishlistedLocal;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isWishlistedLocal = widget.isWishlisted;
    
    // Animation controller for the staggered entrance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleWishlistClick() {
    setState(() {
      _isWishlistedLocal = !_isWishlistedLocal;
    });
    widget.onToggleWishlist(); 
  }

  // --- Helper to format currency ---
  String _formatPrice(double amount) {
    if (amount <= 0) return "Included";
    return "₹ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.product['name']?.toString() ?? 'Unnamed Jewelry';
    final String description = widget.product['description']?.toString() ?? 'An exquisite piece of jewelry crafted with precision.';
    final String sku = widget.product['sku']?.toString() ?? 'SKU-UNKNOWN';
    final String purity = widget.product['purity']?.toString() ?? '22K';
    final String status = widget.product['status']?.toString().replaceAll('_', ' ') ?? 'AVAILABLE';

    final double netWeight = (widget.product['netWeight'] ?? widget.product['grossWeight'] ?? 0.0).toDouble();
    final double metalRate = (widget.product['metalRate'] ?? 0.0).toDouble();
    final double makingCharges = (widget.product['makingCharges'] ?? 0.0).toDouble();
    final double stoneCharges = (widget.product['stoneCharges'] ?? 0.0).toDouble();

    final double goldValue = netWeight * metalRate;
    final double finalPrice = goldValue + makingCharges + stoneCharges;
    final String formattedWeight = "${netWeight.toStringAsFixed(2)}g";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Parallax Product Image App Bar ---
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            stretch: true, // Allows over-scrolling bounce effect
            backgroundColor: const Color(0xFF0F0F1A),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A).withAlpha((0.6 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F1A).withAlpha((0.6 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isWishlistedLocal ? Icons.favorite : Icons.favorite_border,
                      color: _isWishlistedLocal ? Colors.redAccent : Colors.white,
                      size: 22,
                    ),
                    onPressed: _handleWishlistClick,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  border: Border(bottom: BorderSide(color: const Color(0xFFD4AF37).withAlpha((0.15 * 255).round()))),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle background glow
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()), blurRadius: 100)],
                      ),
                    ),
                    // The main icon/image
                    Hero(
                      tag: 'product_image_${widget.product['id']}',
                      child: const Icon(Icons.diamond_outlined, size: 140, color: Color(0xFFD4AF37)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. Staggered Animated Details ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Title and Badges Entrance
                  _buildAnimatedSlide(
                    delay: 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildBadge("100% HALLMARKED", const Color(0xFFD4AF37).withAlpha((0.15 * 255).round()), const Color(0xFFD4AF37)),
                            const SizedBox(width: 8),
                            _buildBadge(status, const Color(0xFF16213E), const Color(0xFFA0A0B8)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(name, style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                        const SizedBox(height: 6),
                        Text("Item Code: $sku", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6C6C80), letterSpacing: 1)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Specifications Entrance
                  _buildAnimatedSlide(
                    delay: 0.3,
                    child: Row(
                      children: [
                        _buildSpecChip(Icons.monitor_weight_outlined, "Net Weight", formattedWeight),
                        const SizedBox(width: 16),
                        _buildSpecChip(Icons.verified_outlined, "Purity", purity),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 36),

                  // Description Entrance
                  _buildAnimatedSlide(
                    delay: 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ABOUT THE DESIGN", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Price Breakdown Entrance
                  _buildAnimatedSlide(
                    delay: 0.7,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E).withAlpha((0.4 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.15 * 255).round())),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("TRANSPARENT PRICING", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5)),
                          const SizedBox(height: 20),
                          
                          _buildPriceRow("Gold Value", "$formattedWeight × ${_formatPrice(metalRate)}", _formatPrice(goldValue)),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF1A1A2E))),
                          
                          _buildPriceRow("Making Charges", "Handcrafted Artistry", _formatPrice(makingCharges)),
                          
                          if (stoneCharges > 0) ...[
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF1A1A2E))),
                            _buildPriceRow("Stone Charges", "Precious Gems", _formatPrice(stoneCharges)),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Total Estimate Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(color: const Color(0xFF0F0F1A), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Estimate", style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(_formatPrice(finalPrice), style: GoogleFonts.inter(fontSize: 22, color: const Color(0xFFD4AF37), fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Padding for the floating action bar
                ],
              ),
            ),
          ),
        ],
      ),

      // --- 3. Floating Bottom Action Bar ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withAlpha((0.95 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.4 * 255).round()), 
                blurRadius: 20, 
                offset: const Offset(0, 10)
              )
            ],
            border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round())),
          ),
          child: Row(
            children: [
              // 1. Dynamic Wishlist Button
              Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: _handleWishlistClick,
                  icon: Icon(
                    _isWishlistedLocal ? Icons.favorite : Icons.favorite_border, 
                    color: _isWishlistedLocal ? Colors.redAccent : const Color(0xFFD4AF37), 
                    size: 20
                  ),
                  label: Text(
                    _isWishlistedLocal ? "SAVED" : "WISHLIST", 
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(20))
                    ),
                  ),
                ),
              ),
              
              // Elegant Divider
              Container(width: 1, height: 30, color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
              
              // 2. Enquire Now Button
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () => _showEnquiryBottomSheet(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(20))
                    ),
                  ),
                  child: Text(
                    "ENQUIRE NOW", 
                    style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Animation Helper ---
  Widget _buildAnimatedSlide({required double delay, required Widget child}) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withAlpha((0.3 * 255).round())),
      ),
      child: Text(text, style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildSpecChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0F0F1A), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String subtitle, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6C6C80))),
          ],
        ),
        Text(amount, style: GoogleFonts.inter(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
  
  void _showEnquiryBottomSheet(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    bool isSubmitting = false;

    // Safely parse the ID to an integer for the API
    final int itemId = int.tryParse(widget.product['id']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              // This padding pushes the sheet up when the keyboard opens!
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF16213E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Enquire About This Piece", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Subject Field
                    TextField(
                      controller: subjectController,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Subject",
                        labelStyle: GoogleFonts.inter(color: const Color(0xFFA0A0B8)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Message Field
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Message",
                        alignLabelWithHint: true,
                        labelStyle: GoogleFonts.inter(color: const Color(0xFFA0A0B8)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.redAccent));
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            await DiscoveryService().submitEnquiry(
                              jewelryItemId: itemId,
                              subject: subjectController.text,
                              message: messageController.text,
                            );
                            
                            if (mounted) {
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Enquiry sent successfully! We will contact you soon."), backgroundColor: Color(0xFFD4AF37), behavior: SnackBarBehavior.floating));
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Failed to send enquiry"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: const Color(0xFFD4AF37).withAlpha((0.5 * 255).round()),
                        ),
                        child: isSubmitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF0F0F1A), strokeWidth: 2))
                          : Text("SEND ENQUIRY", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}