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

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final compact = cardConstraints.maxWidth < 190;
        final padding = compact ? 12.0 : 16.0;
        final iconSize = compact ? 30.0 : 34.0;
        final titleFontSize = compact ? 13.0 : 14.0;
        final valueFontSize = compact ? 23.0 : 26.0;
        final headerGap = compact ? 12.0 : 18.0;
        final barGap = compact ? 14.0 : 20.0;
        final bottomGap = compact ? 8.0 : 12.0;

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
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accentColor.withOpacity(0.25),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: compact ? 16 : 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFE6EDF3),
                          fontWeight: FontWeight.w700,
                          fontSize: titleFontSize,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: headerGap),

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
                            const pointerWidth = 18.0;
                            final maxPointerLeft = (barWidth - pointerWidth)
                                .clamp(0.0, double.infinity);
                            final pointerLeft =
                                (barWidth * percent) - (pointerWidth / 2);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formattedValue(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: pointerColor,
                                      fontSize: valueFontSize,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: barGap),
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
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Positioned(
                                      left: pointerLeft.clamp(
                                        0,
                                        maxPointerLeft,
                                      ),
                                      top: -8,
                                      child: Container(
                                        width: pointerWidth,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: pointerColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.65,
                                            ),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: pointerColor.withOpacity(
                                                0.35,
                                              ),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: bottomGap),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
      },
    );
  }
}
