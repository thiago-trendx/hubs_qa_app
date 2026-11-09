import 'package:flutter/material.dart';

import '../diagnostics/smoke_test_screen.dart';
import '../sleep/sleep_write_tab.dart';
import '../workout/workout_write_tab.dart';
import 'history_tab.dart';
import 'metric_write_tab.dart';
import 'write_log.dart';

class WriteDataScreen extends StatefulWidget {
  const WriteDataScreen({super.key});

  @override
  State<WriteDataScreen> createState() => _WriteDataScreenState();
}

class _WriteDataScreenState extends State<WriteDataScreen> {
  final _log = WriteLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escrever dado de teste'),
          actions: [
            IconButton(
              tooltip: 'Diagnóstico de plataforma',
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SmokeTestScreen())),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Métrica'),
              Tab(text: 'Sono'),
              Tab(text: 'Treino'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MetricWriteTab(log: _log),
            SleepWriteTab(log: _log),
            WorkoutWriteTab(log: _log),
            HistoryTab(log: _log),
          ],
        ),
      ),
    );
  }
}
