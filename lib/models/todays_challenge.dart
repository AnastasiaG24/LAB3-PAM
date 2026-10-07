import 'package:equatable/equatable.dart';

class TodaysChallenge extends Equatable {
  const TodaysChallenge({
    required this.title,
    required this.activity,
    required this.completed,
    required this.total,
  });

  factory TodaysChallenge.fromJson(Map<String, dynamic> json) {
    return TodaysChallenge(
      title: json['title'] as String,
      activity: json['activity'] as String,
      completed: (json['completed'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );
  }

  final String title;
  final String activity;
  final int completed;
  final int total;

  @override
  List<Object?> get props => [title, activity, completed, total];
}
