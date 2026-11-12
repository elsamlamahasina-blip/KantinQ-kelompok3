import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double punchPositionPercent; // 0.0 to 1.0 (default: 0.65)
  final double cornerRadius;

  TicketClipper({
    this.punchRadius = 12.0,
    this.punchPositionPercent = 0.68,
    this.cornerRadius = 16.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final punchY = size.height * punchPositionPercent;

    // Start at top-left with rounded corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge to top-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right edge down to punch hole
    path.lineTo(size.width, punchY - punchRadius);
    path.arcToPoint(
      Offset(size.width, punchY + punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Right edge down to bottom-right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);

    // Bottom edge to bottom-left corner
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left edge up to punch hole
    path.lineTo(0, punchY + punchRadius);
    path.arcToPoint(
      Offset(0, punchY - punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Left edge back to top-left corner
    path.lineTo(0, cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) =>
      oldClipper.punchRadius != punchRadius ||
      oldClipper.punchPositionPercent != punchPositionPercent ||
      oldClipper.cornerRadius != cornerRadius;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = const Color(0xFFDEE2E6),
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}
