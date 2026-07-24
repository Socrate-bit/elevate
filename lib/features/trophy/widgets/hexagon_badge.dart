import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A flat-top hexagonal badge filled with [color] (soft inner gradient + drop
/// shadow), with a centered white Material [icon]. Sized to [size] x [size].
class HexagonBadge extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const HexagonBadge({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(color: color),
        child: Center(
          child: Icon(icon, size: size * 0.42, color: Colors.white),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;

  _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);

    // Drop shadow beneath the badge.
    canvas.drawShadow(path, color.withValues(alpha: 0.5), 8, false);

    // Soft top-to-bottom gradient so the badge reads with depth.
    final rect = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.white, 0.18)!,
          color,
          Color.lerp(color, Colors.black, 0.14)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, fill);

    // Subtle inner highlight ring.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawPath(path, ring);
  }

  /// Flat-top regular hexagon inscribed in [size], with slightly rounded joins.
  Path _hexPath(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = math.min(w, h) / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      // Flat-top: start at -30° and step 60°.
      final angle = (math.pi / 180) * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) =>
      oldDelegate.color != color;
}
