import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../domain/category_entity.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/managers/ui_manager.dart';
import '../../../core/extensions/list_extensions.dart';

/// Custom donut chart widget for category spending visualization.
///
/// Renders a circular donut chart using CustomPaint with colored segments
/// representing spending proportions. Center displays total amount spent.
/// Each segment uses category color for visual consistency.
///
/// Dynamic sizing: All dimensions scale with widget size (no hardcoded pixels)
class DonutChart extends StatelessWidget {
  final Map<String, double> data;          // categoryId → amount
  final List<CategoryEntity> categories;

  const DonutChart({
    super.key,
    required this.data,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (sum, value) => sum + value);

    return CustomPaint(
      painter: DonutChartPainter(
        data: data,
        categories: categories,
        total: total,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              UIManager.formatAmount(total),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for rendering donut chart segments.
///
/// Draws colored arc segments using category colors with a 60% inner radius
/// for the donut effect. Each segment's sweep angle is proportional to its
/// spending amount relative to the total.
class DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<CategoryEntity> categories;
  final double total;

  DonutChartPainter({
    required this.data,
    required this.categories,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6; // 60% inner radius for donut effect

    double startAngle = -math.pi / 2; // Start at top

    for (final entry in data.entries) {
      final category = categories.firstWhereOrNull(
        (c) => c.id == entry.key,
      ) ?? const CategoryEntity(
        id: 'unknown',
        name: 'Unknown',
        icon: 'category',
        color: '9E9E9E',
      );

      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = IconUtils.getColorFromHex(category.color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
