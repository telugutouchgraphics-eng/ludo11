import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';

class CustomGameButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final LinearGradient gradient;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final String? badge;

  const CustomGameButton({
    super.key,
    required this.text,
    this.icon,
    required this.gradient,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 54.0,
    this.badge,
  });

  @override
  State<CustomGameButton> createState() => _CustomGameButtonState();
}

class _CustomGameButtonState extends State<CustomGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        SoundService.instance.playTokenMove();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(0.0, _isPressed ? 3.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: _isPressed ? 2 : 6,
              offset: Offset(0, _isPressed ? 2 : 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Shine highlight
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              height: widget.height * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
              ),
            ),

            // Content
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Optional Badge
            if (widget.badge != null)
              Positioned(
                top: 4,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
