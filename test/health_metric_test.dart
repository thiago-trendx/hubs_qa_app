import 'package:flutter_test/flutter_test.dart';
import 'package:hubs_qa_app/core/health_metric.dart';

void main() {
  group('HealthMetric.parse', () {
    test('accepts plain numbers', () {
      expect(HealthMetric.steps.parse('1234'), 1234.0);
    });

    test('accepts comma as decimal separator', () {
      expect(HealthMetric.weight.parse('70,5'), 70.5);
    });

    test('rejects empty or non-numeric input', () {
      expect(HealthMetric.heartRate.parse(''), isNull);
      expect(HealthMetric.heartRate.parse('abc'), isNull);
    });
  });

  group('HealthMetric.validate', () {
    test('accepts a value within range', () {
      expect(HealthMetric.bloodOxygen.validate('98'), isNull);
    });

    test('rejects a value below the minimum', () {
      expect(HealthMetric.heartRate.validate('5'), isNotNull);
    });

    test('rejects a value above the maximum', () {
      expect(HealthMetric.bloodOxygen.validate('150'), isNotNull);
    });

    test('rejects non-numeric input', () {
      expect(HealthMetric.weight.validate('abc'), isNotNull);
    });
  });

  test('every metric exposes a valid HealthDataUnit', () {
    for (final metric in HealthMetric.values) {
      expect(metric.unit, isNotNull);
    }
  });

  test('only the metrics Health Connect stores as intervals are flagged as such', () {
    expect(HealthMetric.steps.isInterval, isTrue);
    expect(HealthMetric.activeEnergyBurned.isInterval, isTrue);
    expect(HealthMetric.distance.isInterval, isTrue);
    expect(HealthMetric.heartRate.isInterval, isFalse);
    expect(HealthMetric.heartRateVariability.isInterval, isFalse);
    expect(HealthMetric.weight.isInterval, isFalse);
    expect(HealthMetric.height.isInterval, isFalse);
    expect(HealthMetric.bodyTemperature.isInterval, isFalse);
    expect(HealthMetric.bloodOxygen.isInterval, isFalse);
  });

  test('HRV and distance carry a platform note for the UI to surface', () {
    expect(HealthMetric.heartRateVariability.note, isNotNull);
    expect(HealthMetric.steps.note, isNull);
  });
}
