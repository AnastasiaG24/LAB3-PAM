import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/fitness_repository.dart';
import 'gym_state.dart';

class GymCubit extends Cubit<GymState> {
  GymCubit(this._repository) : super(const GymLoading());

  static const loadErrorMessage = 'Could not load gym details.';

  final FitnessRepository _repository;

  Future<void> load() async {
    emit(const GymLoading());
    try {
      final details = await _repository.fetchGymDetails();
      if (!isClosed) emit(GymSuccess(details));
    } catch (_) {
      if (!isClosed) emit(const GymError(loadErrorMessage));
    }
  }
}
