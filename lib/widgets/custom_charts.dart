import 'dart:math';
import 'package:flutter/material.dart';

/// Renders a modern, animated weekly bar chart with rounded corners and gradients.
class WeeklyBarChart extends StatelessWidget {
  final List<double> data; // 7 values representing Mon-Sun
  final List<String> labels;
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.data,
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.isEmpty ? 1.0 : data.reduce(max);
    final displayMax = maxVal == 0 ? 10.0 : maxVal;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final rawValue = data[index];
          final percent = (rawValue / displayMax).clamp(0.0, 1.0);
          final barHeight = percent * (height - 30); // Leave room for labels

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Pop-up review count on hover/display
                if (rawValue > 0)
                  Text(
                    rawValue.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  const Text('', style: TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                // The actual bar
                Container(
                  height: barHeight == 0 ? 6 : barHeight,
                  width: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: barHeight == 0
                        ? null
                        : LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.6),
                            ],
                          ),
                    color: barHeight == 0
                        ? (theme.brightness == Brightness.dark
                            ? const Color(0xFF2E2C3D)
                            : const Color(0xFFE0E0E0))
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// A custom circular progress ring painter for study progress
class CircularProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;

  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final trackColor = theme.brightness == Brightness.dark
        ? const Color(0xFF2E2C3D)
        : const Color(0xFFEFEFF4);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              primaryColor: primaryColor,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Draw the background circle track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw the animated sweep arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.6),
          primaryColor,
        ],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
