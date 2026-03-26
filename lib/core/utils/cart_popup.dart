import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPopup {
  static void show({
    required BuildContext context,
    required bool isAdded,
    required String itemName,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CartPillWidget(
        isAdded: isAdded,
        itemName: itemName,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _CartPillWidget extends StatefulWidget {
  final bool isAdded;
  final String itemName;
  final VoidCallback onDismiss;

  const _CartPillWidget({
    required this.isAdded,
    required this.itemName,
    required this.onDismiss,
  });

  @override
  State<_CartPillWidget> createState() => _CartPillWidgetState();
}

class _CartPillWidgetState extends State<_CartPillWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    // Smooth slide UP from the bottom
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 2), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );

    _controller.forward();

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = widget.isAdded ? const Color(0xFFD4AF37) : const Color(0xFFA0A0B8);
    final IconData icon = widget.isAdded ? Icons.shopping_bag : Icons.remove_shopping_cart;
    final String actionText = widget.isAdded ? "Added to Bag" : "Removed from Bag";

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0), // Floats just above the bottom screen edge
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E).withAlpha((0.95 * 255).round()), // Dark premium background
                  borderRadius: BorderRadius.circular(30), // Perfect Pill Shape
                  border: Border.all(color: highlightColor.withAlpha((0.3 * 255).round()), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha((0.4 * 255).round()), blurRadius: 15, offset: const Offset(0, 5)),
                    BoxShadow(color: highlightColor.withAlpha((0.15 * 255).round()), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Hugs the content tightly
                  children: [
                    Icon(icon, color: highlightColor, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      actionText,
                      style: GoogleFonts.inter(
                        color: Colors.white, 
                        fontSize: 13, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Item Name (truncated if it's too long)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        "• ${widget.itemName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA0A0B8), 
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}