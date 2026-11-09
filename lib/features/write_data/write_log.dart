import 'package:flutter/foundation.dart';

/// One past write attempt (métrica, sono ou treino), kept only in memory for
/// the current app session — just enough for the QA engineer to glance back
/// at what was sent without switching to the native Health/Fitness app.
class WriteLogEntry {
  WriteLogEntry({required this.title, required this.subtitle, required this.success}) : loggedAt = DateTime.now();

  /// What was written, e.g. "Passos: 123 contagem" or "Treino: Corrida".
  final String title;

  /// Extra detail: error message on failure, or a short summary on success.
  final String subtitle;

  final bool success;
  final DateTime loggedAt;

  String get timeLabel =>
      '${loggedAt.hour.toString().padLeft(2, '0')}:${loggedAt.minute.toString().padLeft(2, '0')}:'
      '${loggedAt.second.toString().padLeft(2, '0')}';
}

/// Shared history across the métrica/sono/treino tabs, capped so a long QA
/// session doesn't grow this unbounded.
class WriteLog extends ChangeNotifier {
  static const _maxEntries = 30;

  final List<WriteLogEntry> entries = [];

  void add(WriteLogEntry entry) {
    entries.insert(0, entry);
    if (entries.length > _maxEntries) entries.removeLast();
    notifyListeners();
  }

  void clear() {
    entries.clear();
    notifyListeners();
  }
}
