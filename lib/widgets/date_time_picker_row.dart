import 'package:flutter/material.dart';

/// A button that opens a date picker then a time picker and reports the
/// combined [DateTime] — used wherever a feature needs a real start/end
/// range (sono, treino) instead of a single "now" instant.
class DateTimePickerRow extends StatelessWidget {
  const DateTimePickerRow({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
    if (time == null) return;

    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return OutlinedButton.icon(
      onPressed: () => _pick(context),
      icon: const Icon(Icons.schedule),
      label: Text('$label: $formatted'),
    );
  }
}
