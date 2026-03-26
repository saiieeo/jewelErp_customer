import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/scheme_service.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {
  bool _showExplore = true; 
  bool _isLoading = true;

  List<Map<String, dynamic>> _activeSchemes = [];
  
  // Mock data for enrolled schemes (until we build the API for it)
  final List<Map<String, dynamic>> _enrolledSchemes = [
    {
      "id": 101,
      "schemeName": "Swarna Samriddhi",
      "totalMonths": 11,
      "monthsPaid": 4,
      "monthlyAmount": 5000,
      "totalSaved": 20000,
      "nextDueDate": "2026-04-05",
      "status": "ACTIVE"
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

  // --- Fetch API Data ---
  Future<void> _fetchSchemes() async {
    try {
      final schemes = await SchemeService().getActiveSchemes();
      if (mounted) {
        setState(() {
          _activeSchemes = schemes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading schemes: $e"), backgroundColor: Colors.redAccent)
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
          "SMART WEALTH", 
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: const Color(0xFFD4AF37))
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showExplore ? "Explore Plans" : "My Portfolio", 
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(
                  _showExplore 
                    ? "Invest in your future with our zero-hassle gold accumulation plans." 
                    : "Track your ongoing investments and upcoming installments.", 
                  style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13, height: 1.4)
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Toggle Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()), 
                borderRadius: BorderRadius.circular(12), 
                border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()))
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton("EXPLORE PLANS", true)),
                  Expanded(child: _buildTabButton("MY PORTFOLIO", false)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Content Area
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _showExplore ? _buildExploreList() : _buildPortfolioList(),
                ),
          ),
        ],
      ),
    );
  }

  // --- Explore List (API Data) ---
  Widget _buildExploreList() {
    if (_activeSchemes.isEmpty) {
      return Center(
        child: Text("No active plans available.", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8)))
      );
    }

    return ListView.builder(
      key: const ValueKey("ExploreList"),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100), 
      itemCount: _activeSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _activeSchemes[index];
        
        // Map API JSON
        final String name = scheme['name'] ?? "Gold Plan";
        final String duration = "${scheme['durationMonths'] ?? 11} Months";
        
        final double amountVal = (scheme['monthlyAmount'] ?? 0.0).toDouble();
        final String amountStr = amountVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
        final String minAmount = "₹$amountStr / mo";
        
        final String description = scheme['description'] ?? "Smart savings plan.";
        final bool isBonus = scheme['bonusMonth'] ?? false;
        final String tagline = isBonus ? "BONUS MONTH INCLUDED" : "SMART SAVINGS";

        final Color cardColor = index % 2 == 0 ? const Color(0xFFD4AF37) : Colors.greenAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardColor.withAlpha((0.3 * 255).round()), width: 1.5),
            boxShadow: [
              BoxShadow(color: cardColor.withAlpha((0.05 * 255).round()), blurRadius: 20, spreadRadius: 2),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF16213E), cardColor.withAlpha((0.15 * 255).round())]
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: cardColor.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(6)),
                      child: Text(tagline, style: GoogleFonts.inter(color: cardColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildSchemeFeatureRow(Icons.calendar_today_outlined, "Duration", duration),
                    const SizedBox(height: 16),
                    _buildSchemeFeatureRow(Icons.account_balance_wallet_outlined, "Starts At", minAmount),
                    const SizedBox(height: 16),
                    _buildSchemeFeatureRow(Icons.card_giftcard_outlined, "Benefit", description, isHighlight: true),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("VIEW DETAILS", style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- Portfolio List (Mocked) ---
  Widget _buildPortfolioList() {
    if (_enrolledSchemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined, size: 60, color: const Color(0xFF16213E).withAlpha((0.8 * 255).round())),
            const SizedBox(height: 20),
            Text("No Active Plans", style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey("PortfolioList"),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      itemCount: _enrolledSchemes.length,
      itemBuilder: (context, index) {
        final plan = _enrolledSchemes[index];
        final double progress = plan['monthsPaid'] / plan['totalMonths'];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.2 * 255).round())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan['schemeName'], style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.greenAccent.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(4)),
                    child: Text(plan['status'], style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Installments Paid", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                  Text("${plan['monthsPaid']} / ${plan['totalMonths']}", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF0F0F1A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Saved", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11)),
                        const SizedBox(height: 4),
                        Text("₹${plan['totalSaved']}", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFF6C6C80).withAlpha((0.3 * 255).round())),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Next Due", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(plan['nextDueDate'], style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helpers ---
  Widget _buildSchemeFeatureRow(IconData icon, String title, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: isHighlight ? const Color(0xFFD4AF37) : const Color(0xFFA0A0B8), size: 20),
        const SizedBox(width: 16),
        Text(title, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(color: isHighlight ? const Color(0xFFD4AF37) : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, bool isExploreTab) {
    bool isSelected = _showExplore == isExploreTab;
    return GestureDetector(
      onTap: () => setState(() => _showExplore = isExploreTab),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent, 
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Text(
            title, 
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFF0F0F1A) : const Color(0xFFA0A0B8), 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              letterSpacing: 1
            )
          )
        ),
      ),
    );
  }
}