import 'package:equatable/equatable.dart';

import 'featured_plan.dart';
import 'home_header.dart';
import 'program_filter.dart';
import 'todays_challenge.dart';
import 'workout_program.dart';

class HomePageData extends Equatable {
  const HomePageData({
    required this.header,
    required this.challenge,
    required this.featuredPlans,
    required this.filters,
    required this.programs,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    final workoutPrograms = json['workoutPrograms'] as Map<String, dynamic>;
    return HomePageData(
      header: HomeHeader.fromJson(json['header'] as Map<String, dynamic>),
      challenge: TodaysChallenge.fromJson(
        json['todaysChallenge'] as Map<String, dynamic>,
      ),
      featuredPlans: _parseList(json['featuredPlans'], FeaturedPlan.fromJson),
      filters: _parseList(workoutPrograms['filters'], ProgramFilter.fromJson),
      programs: _parseList(workoutPrograms['items'], WorkoutProgram.fromJson),
    );
  }

  final HomeHeader header;
  final TodaysChallenge challenge;
  final List<FeaturedPlan> featuredPlans;
  final List<ProgramFilter> filters;
  final List<WorkoutProgram> programs;

  String get initialFilterId {
    for (final filter in filters) {
      if (filter.selected) return filter.id;
    }
    return ProgramFilter.allId;
  }

  @override
  List<Object?> get props => [
    header,
    challenge,
    featuredPlans,
    filters,
    programs,
  ];
}

List<T> _parseList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return (raw as List<dynamic>)
      .map((item) => fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}
