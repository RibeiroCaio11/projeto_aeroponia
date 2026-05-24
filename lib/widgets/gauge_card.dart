import 'package:flutter/material.dart';

class GaugeRange {
  final double startValue;
  final double endValue;
  final Color color;

  const GaugeRange({
    required this.startValue,
    required this.endValue,
    required this.color,
  });
}

class GaugeCard extends StatelessWidget {
  final String title;
  final double? value;
  final String unit;
  final double min;
  final double max;
  final List<GaugeRange> ranges;
  final IconData icon;
  final Color accentColor;
  final int precision;

  const GaugeCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.ranges,
    this.icon = Icons.sensors,
    this.accentColor = const Color(0xFF39D353),
    this.precision = 1,
  });

  double _percentValue() {
    if (value == null) return 0;

    final clampedValue = value!.clamp(min, max);
    return ((clampedValue - min) / (max - min)).clamp(0.0, 1.0);
  }

  Color _getPointerColor() {
    if (value == null) return const Color(0xFF8B949E);

    for (final range in ranges) {
      if (value! >= range.startValue && value! <= range.endValue) {
        return range.color;
      }
    }

    return accentColor;
  }

  List<double> _getStops() {
    final stops = <double>[];

    for (final range in ranges) {
      final start = ((range.startValue - min) / (max - min)).clamp(0.0, 1.0);
      final end = ((range.endValue - min) / (max - min)).clamp(0.0, 1.0);

      stops.add(start);
      stops.add(end);
    }

    return stops;
  }

  List<Color> _getColors() {
    final colors = <Color>[];

    for (final range in ranges) {
      colors.add(range.color);
      colors.add(range.color);
    }

    return colors;
  }

  String _formattedValue() {
    if (value == null) return '--';
    final suffix = unit.isEmpty ? '' : ' $unit';
    return '${value!.toStringAsFixed(precision)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final percent = _percentValue();
    final pointerColor = _getPointerColor();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
        boxShadow: [
          BoxShadow(
            color: pointerColor.withOpacity(value == null ? 0.02 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withOpacity(0.25)),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Expanded(
              child: value == null
                  ? Center(
                      child: Text(
                        _formattedValue(),
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth;
                        final pointerLeft = (barWidth * percent) - 30;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _formattedValue(),
                              style: TextStyle(
                                color: pointerColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: _getColors(),
                                      stops: _getStops(),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),

                                Positioned(
                                  left: pointerLeft.clamp(0, barWidth - 60),
                                  top: -8,
                                  child: Container(
                                    width: 18,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: pointerColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.65),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: pointerColor.withOpacity(0.35),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  min.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  max.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
