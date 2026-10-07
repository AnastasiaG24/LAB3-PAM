import 'package:equatable/equatable.dart';

import '../../models/gym_details.dart';

sealed class GymState extends Equatable {
  const GymState();

  @override
  List<Object?> get props => [];
}

final class GymLoading extends GymState {
  const GymLoading();
}

final class GymSuccess extends GymState {
  const GymSuccess(this.details);

  final GymDetails details;

  @override
  List<Object?> get props => [details];
}

final class GymError extends GymState {
  const GymError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
