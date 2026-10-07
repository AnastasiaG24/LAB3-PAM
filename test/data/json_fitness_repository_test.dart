import 'package:fitness_lab2/data/json_fitness_repository.dart';
import 'package:fitness_lab2/models/program_filter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();

  @override
  Future<String> loadString(String key, {bool cache = true}) async => content;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JsonFitnessRepository with the bundled lab JSON', () {
    final repository = JsonFitnessRepository(latency: Duration.zero);

    test('parses the home page', () async {
      final home = await repository.fetchHomePage();

      expect(home.header.greeting, 'Good Morning');
      expect(home.challenge.activity, 'Running');
      expect(home.challenge.completed, 15);
      expect(home.challenge.total, 20);
      expect(home.featuredPlans.map((p) => p.id), ['fp001', 'fp002']);
      expect(home.filters.map((f) => f.id), [
        'all',
        'pilates',
        'cardio',
        'boxing',
        'yoga',
      ]);
      expect(home.initialFilterId, ProgramFilter.allId);
      expect(home.programs.map((p) => p.id), ['wp001', 'wp002', 'wp003']);
      expect(home.programs[1].isPro, isTrue);
      expect(home.programs[2].calories, 260);
    });

    test('parses the gym details page', () async {
      final details = await repository.fetchGymDetails();

      expect(details.gym.name, 'Mid City Gym Training');
      expect(details.gym.reviewCount, 1232);
      expect(details.gym.amenities.map((a) => a.name), ['Showers', 'Lockers']);
      expect(details.gym.pricing.amountLabel, r'$69.00');
      expect(details.gym.pricing.periodLabel, '/week');
      expect(details.reserveLabel, 'Reserve');
      expect(details.reserveEnabled, isTrue);
    });
  });

  group('JsonFitnessRepository with broken data', () {
    test('throws on invalid JSON', () {
      final repository = JsonFitnessRepository(
        bundle: _StringBundle('{not json'),
        latency: Duration.zero,
      );
      expect(repository.fetchHomePage(), throwsFormatException);
    });

    test('throws when the page section is missing', () {
      final repository = JsonFitnessRepository(
        bundle: _StringBundle('{}'),
        latency: Duration.zero,
      );
      expect(repository.fetchGymDetails(), throwsFormatException);
    });

    test('throws when a field has the wrong type', () {
      final repository = JsonFitnessRepository(
        bundle: _StringBundle('{"fitnessHomePage": {"header": 1}}'),
        latency: Duration.zero,
      );
      expect(repository.fetchHomePage(), throwsA(isA<TypeError>()));
    });
  });
}
