import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/profile_service.dart';

class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  List<Map<String, dynamic>> _enquiries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    try {
      final data = await ProfileService().getMyEnquiries();
      if (mounted) {
        setState(() {
          _enquiries = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load enquiries."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "Unknown Date";
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString.split('T')[0];
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
          "MY ENQUIRIES",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFD4AF37),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _enquiries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _enquiries.length,
                  itemBuilder: (context, index) {
                    final enquiry = _enquiries[index];
                    return _buildEnquiryCard(enquiry);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: const Color(0xFF16213E).withAlpha((0.8 * 255).round())),
          const SizedBox(height: 20),
          Text("No Enquiries Yet", style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Questions about our jewelry will appear here.", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEnquiryCard(Map<String, dynamic> enquiry) {
    final String subject = enquiry['subject'] ?? 'No Subject';
    final String message = enquiry['message'] ?? '';
    final String status = enquiry['status'] ?? 'OPEN';
    final String date = _formatDate(enquiry['createdAt']);
    final String? itemName = enquiry['jewelryItemName'];
    final String? imageUrl = enquiry['imageUrl']; // Extracting the Image URL!

    final bool isResponded = status.toUpperCase() == "RESPONDED";

    return GestureDetector(
      onTap: () {
        // 🚨 Navigate to the full detail screen when tapped 🚨
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnquiryDetailScreen(enquiry: enquiry, date: date),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isResponded ? Colors.greenAccent.withAlpha((0.1 * 255).round()) : const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: isResponded ? Colors.greenAccent : const Color(0xFFD4AF37),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(date, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),

            Text(subject, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (itemName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(itemName, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            Text("You asked:", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              message, 
              style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 14, height: 1.4),
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, // Keep the card clean
            ),

            // 🚨 NEW: Show an attachment icon if an image exists 🚨
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.attach_file, color: Color(0xFFD4AF37), size: 14),
                  const SizedBox(width: 6),
                  Text("1 Attachment Included", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🚨 NEW SCREEN: Enquiry Detail Screen (Shows the Image and Full Conversation)
// ============================================================================

class EnquiryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> enquiry;
  final String date;

  const EnquiryDetailScreen({super.key, required this.enquiry, required this.date});

  @override
  Widget build(BuildContext context) {
    final String subject = enquiry['subject'] ?? 'No Subject';
    final String message = enquiry['message'] ?? '';
    final String status = enquiry['status'] ?? 'OPEN';
    final String? itemName = enquiry['jewelryItemName'];
    final String? adminResponse = enquiry['adminResponse'];
    final String? imageUrl = enquiry['imageUrl'];

    final bool isResponded = status.toUpperCase() == "RESPONDED";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ENQUIRY DETAILS",
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isResponded ? Colors.greenAccent.withAlpha((0.1 * 255).round()) : const Color(0xFFD4AF37).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: isResponded ? Colors.greenAccent : const Color(0xFFD4AF37),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(date, style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // Subject
            Text(subject, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            if (itemName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(itemName, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
            const SizedBox(height: 32),

            // 🚨 IMAGE VIEWER 🚨
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              Text("REFERENCE IMAGE", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF16213E), // Background color while loading
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // Shows the whole image without cropping
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, color: Color(0xFF6C6C80), size: 40),
                              const SizedBox(height: 8),
                              Text("Failed to load image", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Customer Message
            Text("YOUR MESSAGE", style: GoogleFonts.inter(color: const Color(0xFF6C6C80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(message, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.5)),

            const SizedBox(height: 40),

            // Admin Response
            if (isResponded && adminResponse != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E).withAlpha((0.5 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round())),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.support_agent, color: Color(0xFFD4AF37), size: 18),
                        const SizedBox(width: 8),
                        Text("STORE REPLY", style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(adminResponse, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.5)),
                  ],
                ),
              ),
            ] else if (!isResponded) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFFA0A0B8), size: 16),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Our jewelry experts are reviewing your request and will reply shortly.", style: GoogleFonts.inter(color: const Color(0xFFA0A0B8), fontSize: 12, height: 1.4))),
                  ],
                ),
              )
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}