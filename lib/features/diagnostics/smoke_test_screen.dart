import 'package:flutter/material.dart';

import '../../core/health_metric.dart';
import '../../core/health_service.dart';

/// Diagnostic screen kept around from fase 1: checks platform plumbing
/// (availability + permissions + one hardcoded write) independent of the
/// real write-data UI. Useful when something on the main screen misbehaves
/// and you need to tell "hub problem" apart from "app bug".
class SmokeTestScreen extends StatefulWidget {
  const SmokeTestScreen({super.key});

  @override
  State<SmokeTestScreen> createState() => _SmokeTestScreenState();
}

class _SmokeTestScreenState extends State<SmokeTestScreen> {
  final _healthService = HealthService();
  final List<String> _log = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _healthService.configure();
  }

  void _addLog(String message) {
    setState(() => _log.insert(0, '${DateTime.now().toIso8601String().substring(11, 19)}  $message'));
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      _addLog('$label: ERRO — $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _checkAvailability() => _run('Disponibilidade', () async {
        final available = await _healthService.isHealthStoreAvailable();
        _addLog(available ? 'Health Connect/HealthKit disponível' : 'Health Connect indisponível no aparelho');
      });

  Future<void> _requestPermissions() => _run('Permissões', () async {
        final granted = await _healthService.requestWritePermissions(
          HealthMetric.values.map((m) => m.dataType).toList(),
        );
        _addLog(granted ? 'Permissões de escrita concedidas' : 'Permissões negadas');
      });

  Future<void> _writeSmokeTestValue() => _run('Escrita', () async {
        const metric = HealthMetric.steps;
        const value = 123.0;
        final result = await _healthService.writeValue(
          metric: metric,
          value: value,
          time: DateTime.now(),
        );
        _addLog(
          result.success
              ? 'Escrito ${value.toStringAsFixed(0)} ${metric.unitLabel} em "${metric.label}" com sucesso'
              : 'Escrita falhou: ${result.errorMessage}',
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de plataforma')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy ? null : _checkAvailability,
                  child: const Text('1. Checar disponibilidade'),
                ),
                FilledButton(
                  onPressed: _busy ? null : _requestPermissions,
                  child: const Text('2. Solicitar permissões'),
                ),
                FilledButton(
                  onPressed: _busy ? null : _writeSmokeTestValue,
                  child: const Text('3. Escrever STEPS=123 agora'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) => Text(_log[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
