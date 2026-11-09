import 'package:flutter/material.dart';

import '../core/health_metric.dart';

class MetricDropdown extends StatelessWidget {
  const MetricDropdown({super.key, required this.value, required this.onChanged});

  final HealthMetric value;
  final ValueChanged<HealthMetric> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HealthMetric>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Métrica',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final metric in HealthMetric.values)
          DropdownMenuItem(value: metric, child: Text('${metric.label} (${metric.unitLabel})')),
      ],
      onChanged: (metric) {
        if (metric != null) onChanged(metric);
      },
    );
  }
}
