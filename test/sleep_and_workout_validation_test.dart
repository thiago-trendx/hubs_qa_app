import 'package:flutter_test/flutter_test.dart';
import 'package:hubs_qa_app/features/sleep/sleep_write_controller.dart';
import 'package:hubs_qa_app/features/workout/workout_write_controller.dart';
import 'package:hubs_qa_app/features/write_data/write_log.dart';

void main() {
  group('SleepWriteController.validateRange', () {
    test('rejects end before or equal to start', () {
      final controller = SleepWriteController(log: WriteLog());
      final now = DateTime(2026, 1, 1, 8);
      controller.setStart(now);
      controller.setEnd(now);
      expect(controller.validateRange(), isNotNull);
    });

    test('rejects a range longer than 24h', () {
      final controller = SleepWriteController(log: WriteLog());
      final start = DateTime(2026, 1, 1, 8);
      controller.setStart(start);
      controller.setEnd(start.add(const Duration(hours: 25)));
      expect(controller.validateRange(), isNotNull);
    });

    test('accepts a sane overnight range', () {
      final controller = SleepWriteController(log: WriteLog());
      final start = DateTime(2026, 1, 1, 23);
      controller.setStart(start);
      controller.setEnd(start.add(const Duration(hours: 7)));
      expect(controller.validateRange(), isNull);
    });
  });

  group('WorkoutWriteController', () {
    test('validateRange rejects end before or equal to start', () {
      final controller = WorkoutWriteController(log: WriteLog());
      final now = DateTime(2026, 1, 1, 8);
      controller.setStart(now);
      controller.setEnd(now);
      expect(controller.validateRange(), isNotNull);
    });

    test('validateCalories accepts empty input (optional field)', () {
      final controller = WorkoutWriteController(log: WriteLog());
      expect(controller.validateCalories(''), isNull);
    });

    test('validateCalories rejects out-of-range values', () {
      final controller = WorkoutWriteController(log: WriteLog());
      expect(controller.validateCalories('-5'), isNotNull);
      expect(controller.validateCalories('999999'), isNotNull);
    });

    test('validateCalories accepts a sane value', () {
      final controller = WorkoutWriteController(log: WriteLog());
      expect(controller.validateCalories('450'), isNull);
    });
  });
}
