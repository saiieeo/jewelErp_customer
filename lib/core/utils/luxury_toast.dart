import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuxuryToast {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CenterHudWidget(
        title: title,
        message: message,
        isSuccess: isSuccess,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _CenterHudWidget extends StatefulWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _CenterHudWidget({
    required this.title,
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_CenterHudWidget> createState() => _CenterHudWidgetState();
}

class _CenterHudWidgetState extends State<_CenterHudWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Slightly faster entrance for a snappy, premium feel
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    // The "Vault Pop" scale effect
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );
    
    // Smooth fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );

    _controller.forward();

    // Auto-dismiss after 2 seconds (Center HUDs should be quick)
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (mounted) {
        // Reverse the animation to melt it away
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
    // Brand colors
    final Color iconColor = widget.isSuccess ? const Color(0xFFD4AF37) : Colors.redAccent;
    final Color glowColor = widget.isSuccess 
        ? const Color(0xFFD4AF37).withAlpha((0.15 * 255).round()) 
        : Colors.redAccent.withAlpha((0.15 * 255).round());

    return SafeArea(
      child: Align(
        alignment: Alignment.center, // Dead center of the screen
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32), // Highly rounded, soft edges
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Premium glassmorphism blur
                  child: Container(
                    width: 220, // Fixed width creates a perfect, balanced box
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withAlpha((0.6 * 255).round()), // Highly transparent base
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round()), width: 1.5), // Subtle light catching edge
                      boxShadow: [
                        BoxShadow(color: glowColor, blurRadius: 40, spreadRadius: 5), // Ambient colored glow
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- LARGE NATIVE ANIMATED ICON ---
                        _AnimatedLuxuryIcon(isSuccess: widget.isSuccess, color: iconColor),
                        
                        const SizedBox(height: 24),
                        
                        // --- Crisp Text Content ---
                        Text(
                          widget.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: iconColor, 
                            fontSize: 11, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 1.5
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white, 
                            fontSize: 13, 
                            height: 1.4,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- The Custom Native Animation Widget ---
class _AnimatedLuxuryIcon extends StatelessWidget {
  final bool isSuccess;
  final Color color;

  const _AnimatedLuxuryIcon({required this.isSuccess, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut, // The "pop and settle" heartbeat feel
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha((0.6 * 255).round()), width: 2),
              color: color.withAlpha((0.1 * 255).round()),
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: color,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}