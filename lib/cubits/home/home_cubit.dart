import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/fitness_repository.dart';
import '../../models/home_page_data.dart';
import '../../models/program_query.dart';
import '../../models/program_sort.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, {this._favoriteIds = const {}})
    : super(const HomeLoading());

  static const loadErrorMessage = 'Could not load workout programs.';

  final FitnessRepository _repository;
  Set<String> _favoriteIds;

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final data = await _repository.fetchHomePage();
      if (!isClosed) _emitReady(data, ProgramQuery.initial(data));
    } catch (_) {
      if (!isClosed) emit(const HomeError(loadErrorMessage));
    }
  }

  /// Returns false when the reload failed but the loaded content was kept.
  Future<bool> refresh() async {
    try {
      final data = await _repository.fetchHomePage();
      if (isClosed) return true;
      final current = state;
      _emitReady(
        data,
        current is HomeReady ? current.query : ProgramQuery.initial(data),
      );
      return true;
    } catch (_) {
      if (isClosed) return false;
      if (state is! HomeReady) emit(const HomeError(loadErrorMessage));
      return false;
    }
  }

  void search(String text) => _updateQuery((q) => q.copyWith(search: text));

  void selectFilter(String filterId) =>
      _updateQuery((q) => q.copyWith(filterId: filterId));

  void changeSort(ProgramSort sort) =>
      _updateQuery((q) => q.copyWith(sort: sort));

  void toggleFavoritesOnly() =>
      _updateQuery((q) => q.copyWith(favoritesOnly: !q.favoritesOnly));

  void updateFavorites(Set<String> favoriteIds) {
    _favoriteIds = favoriteIds;
    final current = state;
    if (current is HomeReady && current.query.favoritesOnly) {
      _emitReady(current.data, current.query);
    }
  }

  void resetQuery() {
    final current = state;
    if (current is! HomeReady) return;
    _emitReady(current.data, ProgramQuery.initial(current.data));
  }

  void _updateQuery(ProgramQuery Function(ProgramQuery current) change) {
    final current = state;
    if (current is! HomeReady) return;
    _emitReady(current.data, change(current.query));
  }

  void _emitReady(HomePageData data, ProgramQuery query) {
    final programs = query.apply(
      data.programs,
      data.filters,
      favoriteIds: _favoriteIds,
    );
    emit(
      programs.isEmpty
          ? HomeEmpty(data: data, query: query)
          : HomeSuccess(data: data, query: query, programs: programs),
    );
  }
}
