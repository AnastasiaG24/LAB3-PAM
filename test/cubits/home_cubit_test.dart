import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_lab2/cubits/home/home_cubit.dart';
import 'package:fitness_lab2/cubits/home/home_state.dart';
import 'package:fitness_lab2/models/program_query.dart';
import 'package:fitness_lab2/models/program_sort.dart';
import 'package:fitness_lab2/models/workout_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  final data = homeData();
  const powerYoga = WorkoutProgram(
    id: 'p4',
    title: 'Power Yoga',
    imageUrl: 'https://example.com/power-yoga.jpg',
    calories: 300,
    durationMinutes: 60,
  );

  HomeSuccess success(ProgramQuery query, List<WorkoutProgram> programs) =>
      HomeSuccess(
        data: data,
        query: query,
        programs: List.unmodifiable(programs),
      );

  test('starts in Loading', () {
    expect(HomeCubit(FakeFitnessRepository()).state, const HomeLoading());
  });

  blocTest<HomeCubit, HomeState>(
    'load emits Loading then Success with every program',
    build: () => HomeCubit(FakeFitnessRepository()),
    act: (cubit) => cubit.load(),
    expect: () => [
      const HomeLoading(),
      success(const ProgramQuery(), [yoga, arms, cardio]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'load emits Empty when the JSON has no programs',
    build: () =>
        HomeCubit(FakeFitnessRepository(home: homeData(programs: const []))),
    act: (cubit) => cubit.load(),
    expect: () => [
      const HomeLoading(),
      HomeEmpty(
        data: homeData(programs: const []),
        query: const ProgramQuery(),
      ),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'load emits Error when the repository throws, retry recovers',
    build: () => HomeCubit(FakeFitnessRepository(failures: 1)),
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    expect: () => [
      const HomeLoading(),
      const HomeError(HomeCubit.loadErrorMessage),
      const HomeLoading(),
      success(const ProgramQuery(), [yoga, arms, cardio]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'filter without matches emits Empty, reset brings Success back',
    build: () => HomeCubit(FakeFitnessRepository()),
    seed: () => success(const ProgramQuery(), [yoga, arms, cardio]),
    act: (cubit) => cubit
      ..selectFilter('pilates')
      ..resetQuery(),
    expect: () => [
      HomeEmpty(
        data: data,
        query: const ProgramQuery(filterId: 'pilates'),
      ),
      success(const ProgramQuery(), [yoga, arms, cardio]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'search narrows the list',
    build: () => HomeCubit(FakeFitnessRepository()),
    seed: () => success(const ProgramQuery(), [yoga, arms, cardio]),
    act: (cubit) => cubit.search('cardio'),
    expect: () => [
      success(const ProgramQuery(search: 'cardio'), [cardio]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'sort reorders the list',
    build: () => HomeCubit(FakeFitnessRepository()),
    seed: () => success(const ProgramQuery(), [yoga, arms, cardio]),
    act: (cubit) => cubit.changeSort(ProgramSort.titleAsc),
    expect: () => [
      success(const ProgramQuery(sort: ProgramSort.titleAsc), [
        arms,
        cardio,
        yoga,
      ]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'refresh keeps the current query and skips Loading',
    build: () => HomeCubit(
      FakeFitnessRepository(
        home: homeData(programs: [yoga, cardio, powerYoga]),
      ),
    ),
    seed: () => success(const ProgramQuery(search: 'yoga'), [yoga]),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      HomeSuccess(
        data: homeData(programs: [yoga, cardio, powerYoga]),
        query: const ProgramQuery(search: 'yoga'),
        programs: const [yoga, powerYoga],
      ),
    ],
  );

  test('refresh applies a query changed while the fetch was running', () async {
    final repo = FakeFitnessRepository(
      home: homeData(programs: [yoga, cardio, powerYoga]),
    )..gate = Completer<void>();
    final cubit = HomeCubit(repo)
      ..emit(success(const ProgramQuery(), [yoga, arms, cardio]));

    final refreshing = cubit.refresh();
    cubit.search('power');
    repo.gate!.complete();

    expect(await refreshing, isTrue);
    expect(
      cubit.state,
      HomeSuccess(
        data: homeData(programs: [yoga, cardio, powerYoga]),
        query: const ProgramQuery(search: 'power'),
        programs: const [powerYoga],
      ),
    );
    await cubit.close();
  });

  test('failed refresh keeps the loaded content and reports false', () async {
    final cubit = HomeCubit(FakeFitnessRepository(failures: 1))
      ..emit(success(const ProgramQuery(), [yoga, arms, cardio]));

    expect(await cubit.refresh(), isFalse);
    expect(cubit.state, success(const ProgramQuery(), [yoga, arms, cardio]));
    await cubit.close();
  });

  blocTest<HomeCubit, HomeState>(
    'failed refresh before any data emits Error',
    build: () => HomeCubit(FakeFitnessRepository(failures: 1)),
    seed: () => const HomeError(HomeCubit.loadErrorMessage),
    act: (cubit) => cubit.refresh(),
    expect: () => <HomeState>[],
    verify: (cubit) =>
        expect(cubit.state, const HomeError(HomeCubit.loadErrorMessage)),
  );

  blocTest<HomeCubit, HomeState>(
    'favorites only shows favorites and follows favorite changes',
    build: () => HomeCubit(FakeFitnessRepository(), favoriteIds: {'p3'}),
    seed: () => success(const ProgramQuery(), [yoga, arms, cardio]),
    act: (cubit) => cubit
      ..toggleFavoritesOnly()
      ..updateFavorites({'p3', 'p1'})
      ..updateFavorites({})
      ..toggleFavoritesOnly(),
    expect: () => [
      success(const ProgramQuery(favoritesOnly: true), [cardio]),
      success(const ProgramQuery(favoritesOnly: true), [yoga, cardio]),
      HomeEmpty(data: data, query: const ProgramQuery(favoritesOnly: true)),
      success(const ProgramQuery(), [yoga, arms, cardio]),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'favorite changes do not emit when favorites only is off',
    build: () => HomeCubit(FakeFitnessRepository()),
    seed: () => success(const ProgramQuery(), [yoga, arms, cardio]),
    act: (cubit) => cubit.updateFavorites({'p1'}),
    expect: () => <HomeState>[],
  );

  test('does not emit after close while loading', () async {
    final repo = FakeFitnessRepository()..gate = Completer<void>();
    final cubit = HomeCubit(repo);

    final loading = cubit.load();
    await cubit.close();
    repo.gate!.complete();

    await expectLater(loading, completes);
    expect(cubit.state, const HomeLoading());
  });

  test('isQueryActive is false only for the initial query', () {
    expect(success(const ProgramQuery(), [yoga]).isQueryActive, isFalse);
    expect(
      success(const ProgramQuery(search: 'x'), [yoga]).isQueryActive,
      isTrue,
    );
  });

  blocTest<HomeCubit, HomeState>(
    'query changes are ignored while not Ready',
    build: () => HomeCubit(FakeFitnessRepository()),
    act: (cubit) => cubit
      ..search('yoga')
      ..selectFilter('cardio')
      ..changeSort(ProgramSort.titleAsc)
      ..resetQuery(),
    expect: () => <HomeState>[],
  );
}
