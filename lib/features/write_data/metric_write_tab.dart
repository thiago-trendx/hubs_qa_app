import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/health_ui_state.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/metric_dropdown.dart';
import '../../widgets/value_input_field.dart';
import 'metric_write_controller.dart';
import 'write_log.dart';

class MetricWriteTab extends StatefulWidget {
  const MetricWriteTab({super.key, required this.log});

  final WriteLog log;

  @override
  State<MetricWriteTab> createState() => _MetricWriteTabState();
}

class _MetricWriteTabState extends State<MetricWriteTab> {
  late final _controller = MetricWriteController(log: widget.log);
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  bool _triedSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.init();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    final message = _controller.lastWriteMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _controller.lastWriteSuccess == true ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final current = _controller.selectedTime;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (time == null) return;

    _controller.selectTime(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _write() async {
    setState(() => _triedSubmit = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _controller.write(_valueController.text);
  }

  @override
  Widget build(BuildContext context) {
    final canWrite =
        _controller.availability == HealthStoreAvailability.available &&
        _controller.permissionState == WritePermissionState.granted &&
        !_controller.isWriting;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvailabilityBanner(),
              _buildPermissionBanner(),
              const SizedBox(height: 16),
              MetricDropdown(
                value: _controller.selectedMetric,
                onChanged: (metric) {
                  _valueController.clear();
                  _controller.selectMetric(metric);
                },
              ),
              if (_controller.selectedMetric.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  _controller.selectedMetric.note!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              ValueInputField(
                metric: _controller.selectedMetric,
                controller: _valueController,
                autovalidate: _triedSubmit,
              ),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: canWrite ? _write : null,
                icon: _controller.isWriting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_alt),
                label: const Text('Escrever no hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBanner() {
    switch (_controller.availability) {
      case HealthStoreAvailability.checking:
        return const InfoBanner(
          color: Colors.blueGrey,
          icon: Icons.hourglass_top,
          message: 'Checando se o hub de saúde está disponível…',
        );
      case HealthStoreAvailability.available:
        return const SizedBox.shrink();
      case HealthStoreAvailability.unavailable:
        return InfoBanner(
          color: Colors.red,
          icon: Icons.error_outline,
          message: Platform.isAndroid
              ? 'Health Connect não encontrado neste aparelho.'
              : 'Apple Health não está disponível neste aparelho.',
          action: Platform.isAndroid
              ? TextButton(onPressed: _controller.installHealthStore, child: const Text('Instalar'))
              : null,
        );
    }
  }

  Widget _buildPermissionBanner() {
    if (_controller.availability != HealthStoreAvailability.available) return const SizedBox.shrink();

    switch (_controller.permissionState) {
      case WritePermissionState.unknown:
      case WritePermissionState.checking:
        return const InfoBanner(color: Colors.blueGrey, icon: Icons.hourglass_top, message: 'Checando permissões…');
      case WritePermissionState.granted:
        return const SizedBox.shrink();
      case WritePermissionState.denied:
        return InfoBanner(
          color: Colors.orange.shade800,
          icon: Icons.lock_outline,
          message: 'Sem permissão de escrita para "${_controller.selectedMetric.label}".',
          action: TextButton(onPressed: _controller.requestPermission, child: const Text('Solicitar')),
        );
    }
  }

  Widget _buildTimePicker() {
    final t = _controller.selectedTime;
    final label =
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule),
            label: Text('Data/hora: $label'),
          ),
        ),
        IconButton(tooltip: 'Usar agora', onPressed: _controller.resetTimeToNow, icon: const Icon(Icons.restore)),
      ],
    );
  }
}
