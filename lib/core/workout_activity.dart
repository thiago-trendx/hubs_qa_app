import 'package:health/health.dart';

/// Curated subset of [HealthWorkoutActivityType] that both Health Connect and
/// HealthKit accept — the plugin throws if you write a type the current
/// platform doesn't support, so we only expose types valid on both.
enum WorkoutActivity {
  running(HealthWorkoutActivityType.RUNNING, 'Corrida'),
  walking(HealthWorkoutActivityType.WALKING, 'Caminhada'),
  biking(HealthWorkoutActivityType.BIKING, 'Ciclismo'),
  hiking(HealthWorkoutActivityType.HIKING, 'Trilha'),
  rowing(HealthWorkoutActivityType.ROWING, 'Remo'),
  elliptical(HealthWorkoutActivityType.ELLIPTICAL, 'Elíptico'),
  stairClimbing(HealthWorkoutActivityType.STAIR_CLIMBING, 'Escada'),
  hiit(HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING, 'HIIT'),
  yoga(HealthWorkoutActivityType.YOGA, 'Yoga'),
  other(HealthWorkoutActivityType.OTHER, 'Outro');

  const WorkoutActivity(this.type, this.label);

  final HealthWorkoutActivityType type;
  final String label;
}
