import 'dart:io' show Platform;

import 'package:health/health.dart';

/// Metrics the QA write tool supports: simple numeric values with a single
/// reading per write (no sleep stages, no workout sessions — those have
/// their own models/screens because they need a real start+end range).
///
/// [min]/[max] are generous sanity bounds (not clinical limits) meant only to
/// catch fat-finger input before it hits the health hub. [decimalPlaces]
/// controls how the value field should round/format what the user types.
enum HealthMetric {
  steps(HealthDataType.STEPS, 'Passos', 'contagem', min: 0, max: 100000, decimalPlaces: 0, isInterval: true),
  heartRate(HealthDataType.HEART_RATE, 'Frequência cardíaca', 'bpm', min: 20, max: 250, decimalPlaces: 0),
  restingHeartRate(HealthDataType.RESTING_HEART_RATE, 'Frequência cardíaca de repouso', 'bpm',
      min: 20, max: 150, decimalPlaces: 0),
  respiratoryRate(HealthDataType.RESPIRATORY_RATE, 'Frequência respiratória', 'resp/min',
      min: 4, max: 60, decimalPlaces: 0),
  heartRateVariability(
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    'Variabilidade da FC (VFC)',
    'ms',
    min: 0,
    max: 300,
    decimalPlaces: 1,
    iosDataType: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    note: 'No Android grava RMSSD; no iOS grava SDNN. São cálculos diferentes — não compare os números entre plataformas.',
  ),
  distance(
    HealthDataType.DISTANCE_DELTA,
    'Distância percorrida',
    'm',
    min: 0,
    max: 100000,
    decimalPlaces: 1,
    isInterval: true,
    iosDataType: HealthDataType.DISTANCE_WALKING_RUNNING,
  ),
  weight(HealthDataType.WEIGHT, 'Peso', 'kg', min: 1, max: 500, decimalPlaces: 2),
  height(HealthDataType.HEIGHT, 'Altura', 'm', min: 0.3, max: 2.5, decimalPlaces: 2),
  bodyTemperature(HealthDataType.BODY_TEMPERATURE, 'Temperatura corporal', '°C',
      min: 25, max: 45, decimalPlaces: 1),
  bloodOxygen(HealthDataType.BLOOD_OXYGEN, 'Saturação de oxigênio', '%', min: 0, max: 100, decimalPlaces: 1),
  activeEnergyBurned(HealthDataType.ACTIVE_ENERGY_BURNED, 'Calorias ativas', 'kcal',
      min: 0, max: 20000, decimalPlaces: 1, isInterval: true);

  const HealthMetric(
    this._androidDataType,
    this.label,
    this.unitLabel, {
    required this.min,
    required this.max,
    required this.decimalPlaces,
    this.isInterval = false,
    HealthDataType? iosDataType,
    this.note,
  }) : _iosDataType = iosDataType;

  final HealthDataType _androidDataType;
  final HealthDataType? _iosDataType;
  final String label;
  final String unitLabel;
  final double min;
  final double max;
  final int decimalPlaces;

  /// True for metrics the health hub stores as a time *range* (e.g. "123
  /// steps between 10:00 and 10:01") rather than a single instant. Health
  /// Connect rejects an interval record whose startTime == endTime, so
  /// [HealthService] needs to give these a non-zero duration when writing.
  final bool isInterval;

  /// Extra context shown under the field, for metrics where the same label
  /// means something subtly different per platform (e.g. HRV).
  final String? note;

  /// The actual [HealthDataType] to read/write on the current platform. Most
  /// metrics use the same type everywhere; a couple (HRV, distance) are
  /// genuinely different data types per platform.
  HealthDataType get dataType => (Platform.isIOS ? _iosDataType : null) ?? _androidDataType;

  HealthDataUnit get unit => dataTypeToUnit[dataType]!;

  /// Parses user input, returning `null` if it isn't a valid number for this
  /// metric. Use [validate] first if you need to show *why* it's invalid.
  double? parse(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  /// Returns a user-facing error message, or `null` if [input] is a valid
  /// value to write for this metric.
  String? validate(String input) {
    final value = parse(input);
    if (value == null) return 'Informe um número válido';
    if (value < min || value > max) {
      return 'Valor fora da faixa esperada ($rangeLabel)';
    }
    return null;
  }

  String get rangeLabel => '${_fmt(min)} a ${_fmt(max)} $unitLabel';

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}
