import 'package:equatable/equatable.dart';

import 'workout_program.dart';

class ProgramFilter extends Equatable {
  const ProgramFilter({
    required this.id,
    required this.name,
    this.selected = false,
  });

  factory ProgramFilter.fromJson(Map<String, dynamic> json) {
    return ProgramFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      selected: json['selected'] as bool? ?? false,
    );
  }

  static const allId = 'all';

  final String id;
  final String name;
  final bool selected;

  bool matches(WorkoutProgram program) {
    if (id == allId) return true;
    return program.title.toLowerCase().contains(name.toLowerCase());
  }

  @override
  List<Object?> get props => [id, name, selected];
}
