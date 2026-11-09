import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/health_metric.dart';

class ValueInputField extends StatelessWidget {
  const ValueInputField({
    super.key,
    required this.metric,
    required this.controller,
    required this.autovalidate,
  });

  final HealthMetric metric;
  final TextEditingController controller;

  /// Only re-validate on every keystroke after the user has tried to submit
  /// once — avoids showing a red error before they've typed anything.
  final bool autovalidate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(metric),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      autovalidateMode: autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      decoration: InputDecoration(
        labelText: 'Valor',
        suffixText: metric.unitLabel,
        border: const OutlineInputBorder(),
        helperText: 'Faixa aceita: ${metric.rangeLabel}',
      ),
      validator: (value) => metric.validate(value ?? ''),
    );
  }
}
