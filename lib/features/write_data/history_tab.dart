import 'package:flutter/material.dart';

import 'write_log.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.log});

  final WriteLog log;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: log,
      builder: (context, _) {
        if (log.entries.isEmpty) {
          return const Center(child: Text('Nenhuma escrita ainda.', style: TextStyle(color: Colors.grey)));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Histórico desta sessão', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(onPressed: log.clear, child: const Text('Limpar')),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: log.entries.length,
                itemBuilder: (context, index) {
                  final entry = log.entries[index];
                  final color = entry.success ? Colors.green.shade700 : Colors.red.shade700;
                  return ListTile(
                    leading: Icon(entry.success ? Icons.check_circle : Icons.error, color: color),
                    title: Text(entry.title),
                    subtitle: Text('${entry.subtitle} · às ${entry.timeLabel}'),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
