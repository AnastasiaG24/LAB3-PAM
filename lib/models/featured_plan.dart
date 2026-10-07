import 'package:equatable/equatable.dart';

class FeaturedPlan extends Equatable {
  const FeaturedPlan({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.frequency,
    required this.actionLabel,
  });

  factory FeaturedPlan.fromJson(Map<String, dynamic> json) {
    return FeaturedPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      duration: json['duration'] as String,
      frequency: json['frequency'] as String,
      actionLabel: json['actionLabel'] as String,
    );
  }

  final String id;
  final String title;
  final String imageUrl;
  final String duration;
  final String frequency;
  final String actionLabel;

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    duration,
    frequency,
    actionLabel,
  ];
}
