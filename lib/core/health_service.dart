import 'package:health/health.dart';

import 'health_metric.dart';
import 'sleep_stage.dart';
import 'workout_activity.dart';

/// Outcome of a single write attempt, with enough detail for the UI/log to
/// show the QA engineer *why* something failed instead of just "deu erro".
class HealthWriteResult {
  const HealthWriteResult.success() : success = true, errorMessage = null;

  const HealthWriteResult.failure(this.errorMessage) : success = false;

  final bool success;
  final String? errorMessage;
}

/// Thin wrapper around the `health` plugin, scoped to what this QA tool
/// needs: configure, request write permissions, and write métrica/sono/treino.
class HealthService {
  final Health _health = Health();

  Future<void> configure() async {
    try {
      await _health.configure();
    } catch (_) {
      // Nothing we can do if the native side fails to initialize; later
      // calls will surface the real problem (e.g. unavailable/denied).
    }
  }

  /// True on iOS. On Android, false if Health Connect isn't installed/available,
  /// or if the platform call itself fails.
  Future<bool> isHealthStoreAvailable() async {
    try {
      return await _health.isHealthConnectAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Android only; opens the Play Store listing for Health Connect.
  Future<void> installHealthConnect() => _health.installHealthConnect();

  Future<bool> hasWritePermission(HealthDataType type) async {
    try {
      final granted = await _health.hasPermissions([type], permissions: [HealthDataAccess.WRITE]);
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestWritePermissions(List<HealthDataType> types) async {
    try {
      return await _health.requestAuthorization(
        types,
        permissions: List.filled(types.length, HealthDataAccess.WRITE),
      );
    } catch (_) {
      return false;
    }
  }

  Future<HealthWriteResult> writeValue({
    required HealthMetric metric,
    required double value,
    required DateTime time,
  }) {
    // Interval types (steps, active energy, distance) need startTime strictly
    // before endTime — Health Connect rejects a zero-length interval. We treat
    // `time` as when the reading ended, with a 1-minute window leading up to it.
    final startTime = metric.isInterval ? time.subtract(const Duration(minutes: 1)) : time;
    return _write(type: metric.dataType, value: value, unit: metric.unit, startTime: startTime, endTime: time);
  }

  /// Sleep stages are always a real time range; the plugin ignores whatever
  /// value we pass for these types; passing 0 is purely a placeholder.
  Future<HealthWriteResult> writeSleepStage({
    required SleepStage stage,
    required DateTime start,
    required DateTime end,
  }) {
    return _write(type: stage.dataType, value: 0, unit: null, startTime: start, endTime: end);
  }

  Future<HealthWriteResult> _write({
    required HealthDataType type,
    required double value,
    required HealthDataUnit? unit,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final ok = await _health.writeHealthData(
        value: value,
        type: type,
        unit: unit,
        startTime: startTime,
        endTime: endTime,
      );
      return ok ? const HealthWriteResult.success() : const HealthWriteResult.failure('Hub recusou a escrita');
    } on HealthException catch (e) {
      return HealthWriteResult.failure(e.toString());
    } on ArgumentError catch (e) {
      return HealthWriteResult.failure(e.message?.toString() ?? e.toString());
    } catch (e) {
      return HealthWriteResult.failure(e.toString());
    }
  }

  Future<HealthWriteResult> writeWorkout({
    required WorkoutActivity activity,
    required DateTime start,
    required DateTime end,
    double? caloriesKcal,
  }) async {
    try {
      final ok = await _health.writeWorkoutData(
        activityType: activity.type,
        start: start,
        end: end,
        totalEnergyBurned: caloriesKcal?.round(),
      );
      return ok ? const HealthWriteResult.success() : const HealthWriteResult.failure('Hub recusou a escrita');
    } on HealthException catch (e) {
      return HealthWriteResult.failure(e.toString());
    } on ArgumentError catch (e) {
      return HealthWriteResult.failure(e.message?.toString() ?? e.toString());
    } catch (e) {
      return HealthWriteResult.failure(e.toString());
    }
  }
}
