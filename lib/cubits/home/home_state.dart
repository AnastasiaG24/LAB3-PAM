import 'package:equatable/equatable.dart';

import '../../models/home_page_data.dart';
import '../../models/program_query.dart';
import '../../models/workout_program.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

sealed class HomeReady extends HomeState {
  const HomeReady({required this.data, required this.query});

  final HomePageData data;
  final ProgramQuery query;

  bool get isQueryActive => query != ProgramQuery.initial(data);

  @override
  List<Object?> get props => [data, query];
}

final class HomeSuccess extends HomeReady {
  const HomeSuccess({
    required super.data,
    required super.query,
    required this.programs,
  });

  final List<WorkoutProgram> programs;

  @override
  List<Object?> get props => [...super.props, programs];
}

final class HomeEmpty extends HomeReady {
  const HomeEmpty({required super.data, required super.query});
}
