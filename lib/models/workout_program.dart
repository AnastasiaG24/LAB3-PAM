import 'package:equatable/equatable.dart';

class WorkoutProgram extends Equatable {
  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.calories,
    required this.durationMinutes,
    this.isPro = false,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      calories: (json['calories'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isPro: json['isPro'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String imageUrl;
  final int calories;
  final int durationMinutes;
  final bool isPro;

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    calories,
    durationMinutes,
    isPro,
  ];
}
