import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class OldGoldScreen extends StatefulWidget {
  const OldGoldScreen({super.key});

  @override
  State<OldGoldScreen> createState() => _OldGoldScreenState();
}

class _OldGoldScreenState extends State<OldGoldScreen> {
  double _weightInGrams = 15.0;
  int _selectedPurity = 22;

  // Mock live rates per gram based on purity
  final Map<int, double> _liveRates = {
    18: 5580.0,
    22: 6850.0,
    24: 7450.0,
  };

  double get _estimatedValue => _weightInGrams * _liveRates[_selectedPurity]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          // --- 1. Premium Header ---
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1A),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "GOLD EXCHANGE",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle background glow
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.5),
                        radius: 1.0,
                        colors: [const Color(0xFFD4AF37).withOpacity(0.15), const Color(0xFF0F0F1A)],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.recycling_rounded, color: Color(0xFFD4AF37), size: 40),
                      const SizedBox(height: 8),
                      Text(
                        "Upgrade Your Legacy",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 2. Interactive Calculator ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ESTIMATE YOUR VALUE", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 20),

                  // Container for the Calculator
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Purity Selector
                        Text("Select Purity (Karat)", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPurityChip(18),
                            _buildPurityChip(22),
                            _buildPurityChip(24),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Weight Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Approx Weight", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                            Text(
                              "${_weightInGrams.toStringAsFixed(1)} g", 
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFD4AF37),
                            inactiveTrackColor: const Color(0xFF0F0F1A),
                            thumbColor: const Color(0xFFD4AF37),
                            overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            value: _weightInGrams,
                            min: 1.0,
                            max: 100.0,
                            divisions: 990,
                            onChanged: (value) {
                              setState(() {
                                _weightInGrams = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 3. Result Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E).withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text("ESTIMATED EXCHANGE VALUE", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        // Formatting number for Indian Rupee style
                        Text(
                          "₹ ${_formatCurrency(_estimatedValue)}",
                          style: GoogleFonts.playfairDisplay(color: const Color(0xFFD4AF37), fontSize: 38, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF0F0F1A), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF6C6C80), size: 14),
                              const SizedBox(width: 6),
                              Text("Based on today's rate: ₹${_liveRates[_selectedPurity]} /g", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 10)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- 4. Call to Action ---
                  ElevatedButton(
                    onPressed: () {
                      debugPrint("Booking Appointment for ${_weightInGrams}g of ${_selectedPurity}K gold");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F0F1A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("BOOK IN-STORE VALUATION", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Center(
                    child: Text(
                      "*Final value is subject to computerized purity testing at the boutique.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 10),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Spacing for BottomNav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Purity Chips
  Widget _buildPurityChip(int karat) {
    bool isSelected = _selectedPurity == karat;
    return GestureDetector(
      onTap: () => setState(() => _selectedPurity = karat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              "${karat}K",
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF0F0F1A) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              karat == 24 ? "99.9%" : karat == 22 ? "91.6%" : "75.0%",
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF0F0F1A).withOpacity(0.7) : const Color(0xFFA0A0B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple string formatter for Indian commas (e.g., 1,00,000)
  String _formatCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}