import 'dart:async';

import 'package:fitness_lab2/main.dart';
import 'package:fitness_lab2/screens/gym_detail_screen.dart';
import 'package:fitness_lab2/screens/program_details_screen.dart';
import 'package:fitness_lab2/widgets/program_card.dart';
import 'package:fitness_lab2/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, FakeFitnessRepository repo) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(FitnessApp(repository: repo));
  }

  testWidgets('shows Loading, then the program list', (tester) async {
    final repo = FakeFitnessRepository()..gate = Completer<void>();
    await pumpApp(tester, repo);

    expect(find.byType(LoadingView), findsOneWidget);

    repo.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(LoadingView), findsNothing);
    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.byType(ProgramCard), findsNWidgets(3));
  });

  testWidgets('shows Error with Retry that reloads', (tester) async {
    final repo = FakeFitnessRepository(failures: 1);
    await pumpApp(tester, repo);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repo.homeCalls, 2);
    expect(find.byType(ProgramCard), findsNWidgets(3));
  });

  testWidgets('filter without matches shows Empty, reset restores', (
    tester,
  ) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pilates'));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byType(ProgramCard), findsNothing);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();

    expect(find.byType(ProgramCard), findsNWidgets(3));
  });

  testWidgets('search filters cards by title', (tester) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'arm');
    await tester.pumpAndSettle();

    expect(find.byType(ProgramCard), findsOneWidget);
    expect(find.text('Arm Strengthening'), findsOneWidget);
  });

  testWidgets('favorite toggled on a card is shared with the details page', (
    tester,
  ) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Add to favorites').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Remove from favorites'), findsOneWidget);

    await tester.tap(find.text('Yoga').last);
    await tester.pumpAndSettle();

    expect(find.byType(ProgramDetailsScreen), findsOneWidget);
    expect(find.text('Remove from favorites'), findsOneWidget);
  });

  testWidgets('Reset filters also clears the search field', (tester) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.byType(EmptyView), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(find.byType(ProgramCard), findsNWidgets(3));
  });

  testWidgets('sort menu reorders the cards', (tester) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Sort programs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title A-Z'));
    await tester.pumpAndSettle();

    final titles = tester
        .widgetList<ProgramCard>(find.byType(ProgramCard))
        .map((card) => card.program.title);
    expect(titles, ['Arm Strengthening', 'Cardio Training', 'Yoga']);
  });

  testWidgets('favorites toggle shows only favorite programs', (tester) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Show only favorites'));
    await tester.pumpAndSettle();
    expect(find.byType(ProgramCard), findsNothing);
    expect(find.byType(EmptyView), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add to favorites').at(2));
    await tester.tap(find.bySemanticsLabel('Show only favorites'));
    await tester.pumpAndSettle();

    final titles = tester
        .widgetList<ProgramCard>(find.byType(ProgramCard))
        .map((card) => card.program.title);
    expect(titles, ['Cardio Training']);
  });

  testWidgets('failed pull-to-refresh keeps the list and shows a message', (
    tester,
  ) async {
    final repo = FakeFitnessRepository();
    await pumpApp(tester, repo);
    await tester.pumpAndSettle();

    repo.failures = 1;
    await tester.fling(find.text('Good Morning'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(ProgramCard), findsNWidgets(3));
    expect(find.text('Could not refresh. Showing saved data.'), findsOneWidget);
  });

  testWidgets('Start Now opens the gym details from the repository', (
    tester,
  ) async {
    await pumpApp(tester, FakeFitnessRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Now'));
    await tester.pumpAndSettle();

    expect(find.byType(GymDetailScreen), findsOneWidget);
    expect(find.text('Mid City Gym Training'), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);
  });

  testWidgets('gym details shows Error with Retry', (tester) async {
    final repo = FakeFitnessRepository();
    await pumpApp(tester, repo);
    await tester.pumpAndSettle();

    repo.failures = 1;
    await tester.tap(find.text('Start Now'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Mid City Gym Training'), findsOneWidget);
  });
}
