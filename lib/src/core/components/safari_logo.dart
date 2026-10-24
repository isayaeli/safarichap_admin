import 'package:flutter/material.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';

/// The "C2 · Progress Trail" monogram: a gold S trail on near-black. Its tail
/// fades into a dim stretch that ends at a cream dot ("where you start"),
/// with the gold showing how far along the trail you are.
///
/// The same painter renders the launcher icons (see tool/generate_app_icons_test.dart).
class SafariLogo extends StatelessWidget {
  final double size;

  /// Draw the rounded near-black tile behind the S.
  final bool withTile;

  const SafariLogo({super.key, this.size = 64, this.withTile = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: SafariLogoPainter(withTile: withTile)),
    );
  }
}

class SafariLogoPainter extends CustomPainter {
  final bool withTile;

  /// Corner radius of the tile as a fraction of its size (0 = square, for
  /// launcher icons the OS masks itself).
  final double tileRadius;

  /// Shrinks the mark inside the canvas (adaptive-icon safe zone).
  final double markScale;

  /// Solid white mark on transparent (Android notification small icon, which
  /// the OS renders from the alpha channel only).
  final bool monochrome;

  SafariLogoPainter({
    this.withTile = true,
    this.tileRadius = 0.235,
    this.markScale = 1.0,
    this.monochrome = false,
  });

  static const tileColor = Color(0xFF121212);
  static const trailColor = Color(0xFF2B2620);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;

    if (withTile && !monochrome) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(s * tileRadius),
        ),
        Paint()..color = tileColor,
      );
    }

    // Normalised 0–1 coordinates, scaled around the centre.
    final inset = (1 - markScale) / 2;
    Offset p(double x, double y) =>
        Offset((inset + x * markScale) * s, (inset + y * markScale) * s);
    final stroke = s * 0.102 * markScale;

    // Dim tail: the stretch of trail still ahead, from the S down to the dot.
    final tail = Path()
      ..moveTo(p(0.64, 0.745).dx, p(0.64, 0.745).dy)
      ..cubicTo(
        p(0.57, 0.785).dx,
        p(0.57, 0.785).dy,
        p(0.41, 0.79).dx,
        p(0.41, 0.79).dy,
        p(0.33, 0.72).dx,
        p(0.33, 0.72).dy,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = monochrome ? Colors.white : trailColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.95
        ..strokeCap = StrokeCap.round,
    );

    // Gold S.
    final trail = Path()
      ..moveTo(p(0.725, 0.305).dx, p(0.725, 0.305).dy)
      ..cubicTo(
        p(0.67, 0.205).dx,
        p(0.67, 0.205).dy,
        p(0.57, 0.18).dx,
        p(0.57, 0.18).dy,
        p(0.49, 0.18).dx,
        p(0.49, 0.18).dy,
      )
      ..cubicTo(
        p(0.37, 0.18).dx,
        p(0.37, 0.18).dy,
        p(0.28, 0.255).dx,
        p(0.28, 0.255).dy,
        p(0.28, 0.355).dx,
        p(0.28, 0.355).dy,
      )
      ..cubicTo(
        p(0.28, 0.455).dx,
        p(0.28, 0.455).dy,
        p(0.37, 0.485).dx,
        p(0.37, 0.485).dy,
        p(0.50, 0.51).dx,
        p(0.50, 0.51).dy,
      )
      ..cubicTo(
        p(0.64, 0.537).dx,
        p(0.64, 0.537).dy,
        p(0.725, 0.575).dx,
        p(0.725, 0.575).dy,
        p(0.725, 0.655).dx,
        p(0.725, 0.655).dy,
      )
      ..cubicTo(
        p(0.725, 0.705).dx,
        p(0.725, 0.705).dy,
        p(0.695, 0.735).dx,
        p(0.695, 0.735).dy,
        p(0.64, 0.745).dx,
        p(0.64, 0.745).dy,
      );
    canvas.drawPath(
      trail,
      Paint()
        ..color = monochrome ? Colors.white : safariChapColors.primaryColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Cream dot: where you start.
    canvas.drawCircle(
      p(0.315, 0.705),
      s * 0.052 * markScale,
      Paint()
        ..color = monochrome
            ? Colors.white
            : safariChapColors.onSecondaryColor!,
    );
  }

  @override
  bool shouldRepaint(covariant SafariLogoPainter oldDelegate) =>
      oldDelegate.withTile != withTile ||
      oldDelegate.tileRadius != tileRadius ||
      oldDelegate.markScale != markScale ||
      oldDelegate.monochrome != monochrome;
}

/// Logo + "SafariChap" wordmark ("Chap" in gold).
class SafariWordmark extends StatelessWidget {
  final double logoSize;
  final Color? textColor;

  const SafariWordmark({super.key, this.logoSize = 44, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafariLogo(size: logoSize),
        SizedBox(width: logoSize * 0.3),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: logoSize * 0.62,
              fontWeight: FontWeight.w700,
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: "Safari"),
              TextSpan(
                text: "Chap",
                style: TextStyle(color: safariChapColors.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
