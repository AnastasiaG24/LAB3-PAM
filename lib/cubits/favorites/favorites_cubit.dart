import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<Set<String>> {
  FavoritesCubit() : super(const <String>{});

  bool isFavorite(String id) => state.contains(id);

  void toggle(String id) {
    final next = Set<String>.of(state);
    if (!next.remove(id)) next.add(id);
    emit(Set.unmodifiable(next));
  }
}
