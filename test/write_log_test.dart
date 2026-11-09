import 'package:flutter_test/flutter_test.dart';
import 'package:hubs_qa_app/features/write_data/write_log.dart';

void main() {
  test('entry carries title/subtitle/success as given', () {
    final entry = WriteLogEntry(title: 'Passos: 123 contagem', subtitle: 'às agora', success: true);
    expect(entry.title, 'Passos: 123 contagem');
    expect(entry.success, isTrue);
  });

  test('WriteLog keeps newest entries first and caps at 30', () {
    final log = WriteLog();
    for (var i = 0; i < 35; i++) {
      log.add(WriteLogEntry(title: 'item $i', subtitle: '', success: true));
    }
    expect(log.entries.length, 30);
    expect(log.entries.first.title, 'item 34');
  });

  test('clear empties the log', () {
    final log = WriteLog()..add(WriteLogEntry(title: 'a', subtitle: '', success: true));
    log.clear();
    expect(log.entries, isEmpty);
  });
}
