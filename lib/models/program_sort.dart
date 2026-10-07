import 'workout_program.dart';

typedef ProgramComparator = int Function(WorkoutProgram a, WorkoutProgram b);

enum ProgramSort {
  none('Default'),
  titleAsc('Title A-Z'),
  caloriesDesc('Most calories'),
  durationAsc('Shortest first');

  const ProgramSort(this.label);

  final String label;

  ProgramComparator? get comparator => switch (this) {
    ProgramSort.none => null,
    ProgramSort.titleAsc => _byTitle,
    ProgramSort.caloriesDesc => (a, b) => _thenByTitle(
      b.calories.compareTo(a.calories),
      a,
      b,
    ),
    ProgramSort.durationAsc => (a, b) => _thenByTitle(
      a.durationMinutes.compareTo(b.durationMinutes),
      a,
      b,
    ),
  };
}

int _byTitle(WorkoutProgram a, WorkoutProgram b) =>
    a.title.toLowerCase().compareTo(b.title.toLowerCase());

int _thenByTitle(int primary, WorkoutProgram a, WorkoutProgram b) =>
    primary != 0 ? primary : _byTitle(a, b);
