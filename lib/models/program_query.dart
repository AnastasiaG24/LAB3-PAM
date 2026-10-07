import 'package:equatable/equatable.dart';

import 'home_page_data.dart';
import 'program_filter.dart';
import 'program_sort.dart';
import 'workout_program.dart';

class ProgramQuery extends Equatable {
  const ProgramQuery({
    this.search = '',
    this.filterId = ProgramFilter.allId,
    this.sort = ProgramSort.none,
    this.favoritesOnly = false,
  });

  factory ProgramQuery.initial(HomePageData data) =>
      ProgramQuery(filterId: data.initialFilterId);

  final String search;
  final String filterId;
  final ProgramSort sort;
  final bool favoritesOnly;

  List<WorkoutProgram> apply(
    List<WorkoutProgram> programs,
    List<ProgramFilter> filters, {
    Set<String> favoriteIds = const {},
  }) {
    final filter = _findFilter(filters);
    final needle = search.trim().toLowerCase();

    final result = programs
        .where((p) => filter == null || filter.matches(p))
        .where((p) => needle.isEmpty || p.title.toLowerCase().contains(needle))
        .where((p) => !favoritesOnly || favoriteIds.contains(p.id))
        .toList();

    final comparator = sort.comparator;
    if (comparator != null) result.sort(comparator);
    return List.unmodifiable(result);
  }

  ProgramFilter? _findFilter(List<ProgramFilter> filters) {
    for (final filter in filters) {
      if (filter.id == filterId) return filter;
    }
    return null;
  }

  ProgramQuery copyWith({
    String? search,
    String? filterId,
    ProgramSort? sort,
    bool? favoritesOnly,
  }) {
    return ProgramQuery(
      search: search ?? this.search,
      filterId: filterId ?? this.filterId,
      sort: sort ?? this.sort,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  @override
  List<Object?> get props => [search, filterId, sort, favoritesOnly];
}
