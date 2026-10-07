import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_lab2/cubits/favorites/favorites_cubit.dart';
import 'package:fitness_lab2/cubits/gym/gym_cubit.dart';
import 'package:fitness_lab2/cubits/gym/gym_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('FavoritesCubit', () {
    blocTest<FavoritesCubit, Set<String>>(
      'toggle adds and removes an id',
      build: FavoritesCubit.new,
      act: (cubit) => cubit
        ..toggle('p1')
        ..toggle('p2')
        ..toggle('p1'),
      expect: () => [
        {'p1'},
        {'p1', 'p2'},
        {'p2'},
      ],
      verify: (cubit) {
        expect(cubit.isFavorite('p2'), isTrue);
        expect(cubit.isFavorite('p1'), isFalse);
      },
    );
  });

  group('GymCubit', () {
    blocTest<GymCubit, GymState>(
      'load emits Loading then Success',
      build: () => GymCubit(FakeFitnessRepository()),
      act: (cubit) => cubit.load(),
      expect: () => [const GymLoading(), const GymSuccess(gymDetails)],
    );

    blocTest<GymCubit, GymState>(
      'load emits Error when the repository throws',
      build: () => GymCubit(FakeFitnessRepository(failures: 1)),
      act: (cubit) => cubit.load(),
      expect: () => [
        const GymLoading(),
        const GymError(GymCubit.loadErrorMessage),
      ],
    );
  });
}
