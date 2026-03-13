import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          "saees Vault", 
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
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
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

                  // --- 4. NEW: Explore Available Schemes ---
                  Text(
                    "EXPLORE NEW SCHEMES",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Horizontal scrolling list of available schemes
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildAvailableSchemeCard(
                          title: "Golden Harvest",
                          duration: "11 Months",
                          benefit: "100% Off on Making Charges",
                          isPremium: true,
                        ),
                        const SizedBox(width: 16),
                        _buildAvailableSchemeCard(
                          title: "Swarna Akshay",
                          duration: "6 Months",
                          benefit: "Flat 50% Off on Wastage",
                          isPremium: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- 5. Recent Invoices / Ledger ---
                  Text(
                    "VAULT LEDGER",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLedgerItem(
                    title: "Scheme Installment",
                    date: "Mar 10, 2026",
                    amount: "₹ 10,000",
                    isCredit: true,
                  ),
                  _buildLedgerItem(
                    title: "Bridal Set Purchase",
                    date: "Feb 14, 2026",
                    amount: "₹ 3,45,000",
                    isCredit: false,
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
            color: const Color(0xFFD4AF37).withOpacity(0.2),
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
                  color: const Color(0xFF0F0F1A).withOpacity(0.7),
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
              color: const Color(0xFF0F0F1A).withOpacity(0.15),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
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
                    Text("Swarna Samruddhi", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("₹ 10,000 / month", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFD4AF37).withOpacity(0.1)),
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
                onPressed: () {},
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

  // NEW: Available Scheme Card UI
  Widget _buildAvailableSchemeCard({required String title, required String duration, required String benefit, required bool isPremium}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF1A1A2E) : const Color(0xFF16213E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPremium ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(duration, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              if (isPremium) const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  benefit,
                  style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                debugPrint("Joining $title");
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(isPremium ? 1.0 : 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                "JOIN NOW", 
                style: GoogleFonts.inter(color: isPremium ? const Color(0xFFD4AF37) : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerItem({required String title, required String date, required String amount, required bool isCredit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(date, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 11)),
              ],
            ),
          ),
          Text(
            "${isCredit ? '+' : '-'} $amount",
            style: GoogleFonts.inter(
              color: isCredit ? Colors.greenAccent : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}