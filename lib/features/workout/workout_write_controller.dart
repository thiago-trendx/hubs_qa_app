import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/health_service.dart';
import '../../core/health_ui_state.dart';
import '../../core/workout_activity.dart';
import '../write_data/write_log.dart';

const double kMaxWorkoutCalories = 20000;

/// Holds the state for the "Treino" tab. A workout is written as a single
/// session (activity type + start/end + optional calories) through the
/// plugin's dedicated `writeWorkoutData`, not the generic value-write path —
/// every activity type maps to the same `WORKOUT` permission, so unlike the
/// métrica/sono tabs, permission here doesn't depend on which activity is picked.
class WorkoutWriteController extends ChangeNotifier {
  WorkoutWriteController({required WriteLog log, HealthService? healthService})
    : _log = log,
      _healthService = healthService ?? HealthService();

  final HealthService _healthService;
  final WriteLog _log;

  WorkoutActivity selectedActivity = WorkoutActivity.values.first;
  DateTime start = DateTime.now().subtract(const Duration(minutes: 30));
  DateTime end = DateTime.now();

  HealthStoreAvailability availability = HealthStoreAvailability.checking;
  WritePermissionState permissionState = WritePermissionState.unknown;

  bool isWriting = false;
  bool? lastWriteSuccess;
  String? lastWriteMessage;

  Future<void> init() async {
    await _healthService.configure();
    await _refreshAvailability();
    await _refreshPermission();
  }

  Future<void> _refreshAvailability() async {
    availability = HealthStoreAvailability.checking;
    notifyListeners();
    final ok = await _healthService.isHealthStoreAvailable();
    availability = ok ? HealthStoreAvailability.available : HealthStoreAvailability.unavailable;
    notifyListeners();
  }

  Future<void> _refreshPermission() async {
    permissionState = WritePermissionState.checking;
    notifyListeners();
    final granted = await _healthService.hasWritePermission(HealthDataType.WORKOUT);
    permissionState = granted ? WritePermissionState.granted : WritePermissionState.denied;
    notifyListeners();
  }

  void selectActivity(WorkoutActivity activity) {
    selectedActivity = activity;
    notifyListeners();
  }

  Future<void> installHealthStore() async {
    await _healthService.installHealthConnect();
    await _refreshAvailability();
  }

  Future<void> requestPermission() async {
    permissionState = WritePermissionState.checking;
    notifyListeners();
    final granted = await _healthService.requestWritePermissions([HealthDataType.WORKOUT]);
    permissionState = granted ? WritePermissionState.granted : WritePermissionState.denied;
    notifyListeners();
  }

  void setStart(DateTime value) {
    start = value;
    notifyListeners();
  }

  void setEnd(DateTime value) {
    end = value;
    notifyListeners();
  }

  String? validateRange() {
    if (!end.isAfter(start)) return 'O fim precisa ser depois do início';
    if (end.difference(start) > const Duration(hours: 24)) return 'Treino maior que 24h — confira as datas';
    return null;
  }

  /// Returns a validation error for the optional calories field, or `null`.
  String? validateCalories(String rawCalories) {
    if (rawCalories.trim().isEmpty) return null;
    final value = double.tryParse(rawCalories.trim().replaceAll(',', '.'));
    if (value == null) return 'Informe um número válido';
    if (value < 0 || value > kMaxWorkoutCalories) return 'Valor fora da faixa esperada (0 a $kMaxWorkoutCalories kcal)';
    return null;
  }

  Future<void> write(String rawCalories) async {
    final rangeError = validateRange();
    final caloriesError = validateCalories(rawCalories);
    final error = rangeError ?? caloriesError;
    if (error != null) {
      lastWriteSuccess = false;
      lastWriteMessage = error;
      notifyListeners();
      return;
    }

    isWriting = true;
    lastWriteSuccess = null;
    lastWriteMessage = null;
    notifyListeners();

    final calories = rawCalories.trim().isEmpty ? null : double.parse(rawCalories.trim().replaceAll(',', '.'));
    final result = await _healthService.writeWorkout(
      activity: selectedActivity,
      start: start,
      end: end,
      caloriesKcal: calories,
    );

    isWriting = false;
    lastWriteSuccess = result.success;
    final duration = end.difference(start);
    lastWriteMessage = result.success
        ? 'Escrito treino "${selectedActivity.label}" (${_durationLabel(duration)})'
        : (result.errorMessage ?? 'Falha desconhecida');

    _log.add(
      WriteLogEntry(
        title: 'Treino — ${selectedActivity.label}: ${_durationLabel(duration)}'
            '${calories != null ? ' · ${calories.toStringAsFixed(0)} kcal' : ''}',
        subtitle: result.success
            ? '${_timeLabel(start)} → ${_timeLabel(end)}'
            : (result.errorMessage ?? 'falha desconhecida'),
        success: result.success,
      ),
    );

    notifyListeners();
  }

  String _timeLabel(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _durationLabel(Duration d) => '${d.inHours}h${(d.inMinutes % 60).toString().padLeft(2, '0')}';
}
