import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeCard extends StatelessWidget {
  final String title;
  final double? value; // Aceita null para o estado inicial
  final String unit;
  final double min;
  final double max;
  final List<GaugeRange> ranges;

  const GaugeCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.ranges,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: value == null
                  ? const Center(child: Text('--'))
                  : SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: min,
                          maximum: max,
                          // Configuração para Semicírculo
                          startAngle: 180,
                          endAngle: 360,
                          canScaleToFit: true,
                          showTicks: false,
                          showLabels: false,
                          ranges: ranges,
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              value: value!,
                              needleLength: 0.7,
                              needleEndWidth: 3,
                              knobStyle: const KnobStyle(knobRadius: 0.08),
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '${value!.toStringAsFixed(1)} $unit',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              angle: 90,
                              positionFactor: 0.8,
                            )
                          ],
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}