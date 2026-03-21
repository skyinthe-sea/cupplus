import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Loads an illustration from assets. Shows [IllustrationPlaceholder] while
/// loading or if the asset doesn't exist — without spamming the console.
class IllustrationImage extends StatefulWidget {
  const IllustrationImage({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
    this.darkOpacity = 0.7,
  });

  final String assetPath;
  final double width;
  final double height;
  final BoxFit fit;
  final double darkOpacity;

  @override
  State<IllustrationImage> createState() => _IllustrationImageState();
}

class _IllustrationImageState extends State<IllustrationImage> {
  bool _exists = false;
  bool _checked = false;

  static final _cache = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    if (_cache.containsKey(widget.assetPath)) {
      if (mounted) setState(() { _exists = _cache[widget.assetPath]!; _checked = true; });
      return;
    }
    try {
      await rootBundle.load(widget.assetPath);
      _cache[widget.assetPath] = true;
      if (mounted) setState(() { _exists = true; _checked = true; });
    } catch (_) {
      _cache[widget.assetPath] = false;
      if (mounted) setState(() { _exists = false; _checked = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_exists) {
      return IllustrationPlaceholder(
        width: widget.width,
        height: widget.height,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget image = Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );

    if (isDark) {
      image = Opacity(opacity: widget.darkOpacity, child: image);
    }

    return image;
  }
}

class IllustrationPlaceholder extends StatelessWidget {
  const IllustrationPlaceholder({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final w = width ?? 80.r;
    final h = height ?? 80.r;

    return CustomPaint(
      size: Size(w, h),
      painter: _XBoxPainter(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
      ),
    );
  }
}

class _XBoxPainter extends CustomPainter {
  _XBoxPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, paint);
  }

  @override
  bool shouldRepaint(_XBoxPainter oldDelegate) => color != oldDelegate.color;
}
