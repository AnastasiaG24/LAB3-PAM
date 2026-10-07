import 'package:fitness_lab2/models/program_query.dart';
import 'package:fitness_lab2/models/program_sort.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  const programs = [yoga, arms, cardio];

  List<String> titles(ProgramQuery query) =>
      query.apply(programs, filters).map((p) => p.title).toList();

  test('default query keeps JSON order', () {
    expect(titles(const ProgramQuery()), [
      'Yoga',
      'Arm Strengthening',
      'Cardio Training',
    ]);
  });

  test('filter matches programs whose title contains the filter name', () {
    expect(titles(const ProgramQuery(filterId: 'cardio')), ['Cardio Training']);
    expect(titles(const ProgramQuery(filterId: 'yoga')), ['Yoga']);
    expect(titles(const ProgramQuery(filterId: 'pilates')), isEmpty);
  });

  test('unknown filter id does not hide programs', () {
    expect(titles(const ProgramQuery(filterId: 'missing')), hasLength(3));
  });

  test('search is case-insensitive and trimmed', () {
    expect(titles(const ProgramQuery(search: '  ARM ')), ['Arm Strengthening']);
    expect(titles(const ProgramQuery(search: 'zzz')), isEmpty);
  });

  test('search and filter combine', () {
    expect(
      titles(const ProgramQuery(search: 'yoga', filterId: 'cardio')),
      isEmpty,
    );
  });

  test('sorts by title', () {
    expect(titles(const ProgramQuery(sort: ProgramSort.titleAsc)), [
      'Arm Strengthening',
      'Cardio Training',
      'Yoga',
    ]);
  });

  test('sorts by calories descending, ties by title', () {
    expect(titles(const ProgramQuery(sort: ProgramSort.caloriesDesc)), [
      'Cardio Training',
      'Arm Strengthening',
      'Yoga',
    ]);
  });

  test('sorts by duration ascending, ties by title', () {
    expect(titles(const ProgramQuery(sort: ProgramSort.durationAsc)), [
      'Cardio Training',
      'Arm Strengthening',
      'Yoga',
    ]);
  });

  test('favorites only keeps programs whose id is a favorite', () {
    const query = ProgramQuery(favoritesOnly: true);
    expect(
      query.apply(programs, filters, favoriteIds: {'p2'}).map((p) => p.title),
      ['Arm Strengthening'],
    );
    expect(query.apply(programs, filters), isEmpty);
  });

  test('result is unmodifiable', () {
    final result = const ProgramQuery().apply(programs, filters);
    expect(() => result.add(yoga), throwsUnsupportedError);
  });
}
