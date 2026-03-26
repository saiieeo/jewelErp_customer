import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String date;
  final String items;
  final String amount;
  final String status;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.date,
    required this.items,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    bool isDelivered = status.toUpperCase() == "DELIVERED";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ORDER DETAILS",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFD4AF37),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Order Status Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderId, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Placed on $date", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDelivered ? Colors.greenAccent.withAlpha((0.1 * 255).round()) : const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: isDelivered ? Colors.greenAccent : const Color(0xFFD4AF37),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- 2. Product Info Section ---
            Text("PRODUCT DETAILS", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.1 * 255).round())),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Purity: 22K Solid Gold", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Net Weight: 24.5g", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 3. Digital Bill / Invoice Preview ---
            Text("INVOICE SUMMARY", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInvoiceRow("Subtotal (Gold Value)", "₹ 3,00,000"),
                  const SizedBox(height: 12),
                  _buildInvoiceRow("Making Charges (12%)", "₹ 36,000"),
                  const SizedBox(height: 12),
                  _buildInvoiceRow("GST (3%)", "₹ 9,000"),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white.withAlpha((0.1 * 255).round())),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TOTAL PAID", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(amount, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 4. Download PDF Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("PDF Generation coming soon..."),
                      backgroundColor: Color(0xFF6C6C80),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: Text("DOWNLOAD INVOICE (PDF)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F0F1A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 13)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}