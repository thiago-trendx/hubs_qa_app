import 'package:health/health.dart';

/// Sleep stages the QA tool can write. Unlike [HealthMetric], these don't take
/// a numeric value — the hub derives the duration from the start/end range,
/// and the `health` plugin ignores whatever value we pass for these types.
enum SleepStage {
  asleep(HealthDataType.SLEEP_ASLEEP, 'Dormindo (tempo total)'),
  awake(HealthDataType.SLEEP_AWAKE, 'Acordado'),
  light(HealthDataType.SLEEP_LIGHT, 'Sono leve'),
  deep(HealthDataType.SLEEP_DEEP, 'Sono profundo'),
  rem(HealthDataType.SLEEP_REM, 'Sono REM');

  const SleepStage(this.dataType, this.label);

  final HealthDataType dataType;
  final String label;
}
