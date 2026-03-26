import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_detail_screen.dart'; 
import '../../profile/data/profile_service.dart'; 

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _firstName = ""; 
  bool _isProcessingPayment = false; // Used for the payment loading state
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final data = await ProfileService().getProfile();
      if (mounted) {
        setState(() {
          _firstName = data['firstName'] ?? "My";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _firstName = "My");
    }
  }

  // --- NEW: Payment Gateway Integration Placeholder ---
  void _showPaymentBottomSheet(BuildContext context, String schemeName, String amountStr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF6C6C80), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 24),
                  
                  Text("PAYMENT SUMMARY", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Scheme", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
                            Text(schemeName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF0F0F1A))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Installment", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
                            Text("8 of 11", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF0F0F1A))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Payable", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(amountStr, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessingPayment 
                        ? null 
                        : () async {
                            setModalState(() => _isProcessingPayment = true);
                            
                            // ==========================================
                            // 🚨 TODO: PAYMENT GATEWAY GOES HERE 🚨
                            // Once backend is ready, you will call:
                            // 1. ApiService().createOrder(schemeId)
                            // 2. Razorpay.open(options)
                            // ==========================================
                            
                            // Simulating network delay for now
                            await Future.delayed(const Duration(seconds: 2));
                            
                            if (context.mounted) {
                              setModalState(() => _isProcessingPayment = false);
                              Navigator.pop(context); // Close sheet
                              
                              // Show Success
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Text("Payment of $amountStr Successful!", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                )
                              );
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: const Color(0xFFD4AF37).withAlpha((0.5 * 255).round()),
                      ),
                      child: _isProcessingPayment 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF0F0F1A), strokeWidth: 2))
                        : Text("PROCEED TO PAY", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final String vaultTitle = _firstName.toLowerCase() == "my" || _firstName.isEmpty 
        ? "My Vault" 
        : "$_firstName's Vault";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          // --- 1. The "Locker" Header ---
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            backgroundColor: const Color(0xFF0F0F1A),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaultTitle, 
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SECURE & ENCRYPTED", 
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD4AF37), 
                            fontSize: 10, 
                            letterSpacing: 2, 
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
                      ),
                      child: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
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
                  
                  // --- 2. The Wealth Card ---
                  _buildWealthCard(),

                  const SizedBox(height: 40),

                  // --- 3. Active Gold Schemes ---
                  Text(
                    "ACTIVE SCHEMES",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSchemeCard(),

                  const SizedBox(height: 40),

                  // --- 4. Previous Orders ---
                  Text(
                    "PREVIOUS ORDERS",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildOrderCard(
                    context,
                    orderId: "#ORD-88392",
                    date: "Feb 14, 2026",
                    items: "22K Gold Bridal Set, Diamond Ring",
                    amount: "₹ 3,45,000",
                    status: "DELIVERED",
                  ),
                  _buildOrderCard(
                    context,
                    orderId: "#ORD-88210",
                    date: "Nov 02, 2025",
                    items: "18K Gold Chain (12g)",
                    amount: "₹ 85,000",
                    status: "DELIVERED",
                  ),
                  _buildOrderCard(
                    context,
                    orderId: "#ORD-89004",
                    date: "Mar 18, 2026",
                    items: "Custom Gold Bangle",
                    amount: "₹ 1,12,000",
                    status: "PROCESSING",
                  ),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildWealthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4AF37), Color(0xFF8B6508)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.diamond, color: Color(0xFF0F0F1A), size: 18),
              const SizedBox(width: 8),
              Text(
                "TOTAL ACCUMULATED VALUE",
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F0F1A).withAlpha((0.7 * 255).round()),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "₹ 1,85,000",
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0F0F1A),
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1A).withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Equivalent Gold", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontSize: 11, fontWeight: FontWeight.w600)),
                    Text("24.8 Grams", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F0F1A)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSchemeCard() {
    // Mock data extracted to variables so we can pass them to the payment sheet
    const String schemeName = "Swarna Samruddhi";
    const String monthlyAmount = "₹ 10,000";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round())),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 8 / 11,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFF0F0F1A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                    Center(
                      child: Text(
                        "8/11",
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schemeName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("$monthlyAmount / month", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round())),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NEXT DUE", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("10 April, 2026", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                // 🚨 WIRED TO THE NEW PAYMENT SHEET 🚨
                onPressed: () => _showPaymentBottomSheet(context, schemeName, monthlyAmount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F0F1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("PAY NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- Tappable Order Card ---
  Widget _buildOrderCard(BuildContext context, {required String orderId, required String date, required String items, required String amount, required String status}) {
    bool isDelivered = status.toUpperCase() == "DELIVERED";
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
              orderId: orderId,
              date: date,
              items: items,
              amount: amount,
              status: status,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withAlpha((0.4 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderId, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDelivered ? Colors.greenAccent.withAlpha((0.1 * 255).round()) : const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status, 
                    style: GoogleFonts.inter(
                      color: isDelivered ? Colors.greenAccent : const Color(0xFFD4AF37), 
                      fontSize: 9, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(items, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withAlpha((0.05 * 255).round())),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                Text(amount, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}