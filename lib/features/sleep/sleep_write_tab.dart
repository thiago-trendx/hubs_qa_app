import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/health_ui_state.dart';
import '../../core/sleep_stage.dart';
import '../../widgets/date_time_picker_row.dart';
import '../../widgets/info_banner.dart';
import '../write_data/write_log.dart';
import 'sleep_write_controller.dart';

class SleepWriteTab extends StatefulWidget {
  const SleepWriteTab({super.key, required this.log});

  final WriteLog log;

  @override
  State<SleepWriteTab> createState() => _SleepWriteTabState();
}

class _SleepWriteTabState extends State<SleepWriteTab> {
  late final _controller = SleepWriteController(log: widget.log);

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
    super.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvailabilityBanner(),
            _buildPermissionBanner(),
            const SizedBox(height: 16),
            DropdownButtonFormField<SleepStage>(
              initialValue: _controller.selectedStage,
              decoration: const InputDecoration(labelText: 'Estágio de sono', border: OutlineInputBorder()),
              items: [
                for (final stage in SleepStage.values) DropdownMenuItem(value: stage, child: Text(stage.label)),
              ],
              onChanged: (stage) {
                if (stage != null) _controller.selectStage(stage);
              },
            ),
            const SizedBox(height: 16),
            DateTimePickerRow(label: 'Início', value: _controller.start, onChanged: _controller.setStart),
            const SizedBox(height: 8),
            DateTimePickerRow(label: 'Fim', value: _controller.end, onChanged: _controller.setEnd),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: canWrite ? _controller.write : null,
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
          message: 'Sem permissão de escrita para "${_controller.selectedStage.label}".',
          action: TextButton(onPressed: _controller.requestPermission, child: const Text('Solicitar')),
        );
    }
  }
}
