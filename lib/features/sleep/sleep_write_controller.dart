import 'package:flutter/foundation.dart';

import '../../core/health_service.dart';
import '../../core/health_ui_state.dart';
import '../../core/sleep_stage.dart';
import '../write_data/write_log.dart';

/// Holds the state for the "Sono" tab. Sleep stages are always a real time
/// range (e.g. "profundo das 00:30 às 01:15"), so this tracks a start *and*
/// end instant instead of the single instant the métrica tab uses.
class SleepWriteController extends ChangeNotifier {
  SleepWriteController({required WriteLog log, HealthService? healthService})
    : _log = log,
      _healthService = healthService ?? HealthService();

  final HealthService _healthService;
  final WriteLog _log;

  SleepStage selectedStage = SleepStage.values.first;
  DateTime start = DateTime.now().subtract(const Duration(hours: 8));
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
    final granted = await _healthService.hasWritePermission(selectedStage.dataType);
    permissionState = granted ? WritePermissionState.granted : WritePermissionState.denied;
    notifyListeners();
  }

  Future<void> selectStage(SleepStage stage) async {
    if (stage == selectedStage) return;
    selectedStage = stage;
    lastWriteSuccess = null;
    lastWriteMessage = null;
    notifyListeners();
    await _refreshPermission();
  }

  Future<void> installHealthStore() async {
    await _healthService.installHealthConnect();
    await _refreshAvailability();
  }

  Future<void> requestPermission() async {
    permissionState = WritePermissionState.checking;
    notifyListeners();
    final granted = await _healthService.requestWritePermissions([selectedStage.dataType]);
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

  /// Returns a validation error for the current start/end, or `null` if OK.
  String? validateRange() {
    if (!end.isAfter(start)) return 'O fim precisa ser depois do início';
    if (end.difference(start) > const Duration(hours: 24)) return 'Intervalo maior que 24h — confira as datas';
    return null;
  }

  Future<void> write() async {
    final error = validateRange();
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

    final result = await _healthService.writeSleepStage(stage: selectedStage, start: start, end: end);

    isWriting = false;
    lastWriteSuccess = result.success;
    final duration = end.difference(start);
    lastWriteMessage = result.success
        ? 'Escrito "${selectedStage.label}" (${_durationLabel(duration)})'
        : (result.errorMessage ?? 'Falha desconhecida');

    _log.add(
      WriteLogEntry(
        title: 'Sono — ${selectedStage.label}: ${_durationLabel(duration)}',
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
