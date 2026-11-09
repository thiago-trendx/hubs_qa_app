import 'package:flutter/foundation.dart';

import '../../core/health_metric.dart';
import '../../core/health_service.dart';
import '../../core/health_ui_state.dart';
import 'write_log.dart';

/// Holds the state for the "Métrica" tab: which metric/value/time is
/// selected, whether the hub is reachable, and whether we're allowed to
/// write the selected metric yet.
class MetricWriteController extends ChangeNotifier {
  MetricWriteController({required WriteLog log, HealthService? healthService})
    : _log = log,
      _healthService = healthService ?? HealthService();

  final HealthService _healthService;
  final WriteLog _log;

  HealthMetric selectedMetric = HealthMetric.values.first;
  DateTime selectedTime = DateTime.now();

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
    final granted = await _healthService.hasWritePermission(selectedMetric.dataType);
    permissionState = granted ? WritePermissionState.granted : WritePermissionState.denied;
    notifyListeners();
  }

  Future<void> selectMetric(HealthMetric metric) async {
    if (metric == selectedMetric) return;
    selectedMetric = metric;
    lastWriteSuccess = null;
    lastWriteMessage = null;
    notifyListeners();
    await _refreshPermission();
  }

  void selectTime(DateTime time) {
    selectedTime = time;
    notifyListeners();
  }

  void resetTimeToNow() => selectTime(DateTime.now());

  Future<void> installHealthStore() async {
    await _healthService.installHealthConnect();
    await _refreshAvailability();
  }

  Future<void> requestPermission() async {
    permissionState = WritePermissionState.checking;
    notifyListeners();
    final granted = await _healthService.requestWritePermissions([selectedMetric.dataType]);
    permissionState = granted ? WritePermissionState.granted : WritePermissionState.denied;
    notifyListeners();
  }

  /// Returns the validation error for [rawValue], or `null` if it's safe to write.
  String? validateValue(String rawValue) => selectedMetric.validate(rawValue);

  Future<void> write(String rawValue) async {
    final error = validateValue(rawValue);
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

    final value = selectedMetric.parse(rawValue)!;
    final result = await _healthService.writeValue(metric: selectedMetric, value: value, time: selectedTime);

    isWriting = false;
    lastWriteSuccess = result.success;
    lastWriteMessage = result.success
        ? 'Escrito ${value.toStringAsFixed(selectedMetric.decimalPlaces)} ${selectedMetric.unitLabel} em "${selectedMetric.label}"'
        : (result.errorMessage ?? 'Falha desconhecida');

    _log.add(
      WriteLogEntry(
        title: '${selectedMetric.label}: ${value.toStringAsFixed(selectedMetric.decimalPlaces)} ${selectedMetric.unitLabel}',
        subtitle: result.success ? 'às ${_timeLabel(selectedTime)}' : (result.errorMessage ?? 'falha desconhecida'),
        success: result.success,
      ),
    );

    notifyListeners();
  }

  String _timeLabel(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
