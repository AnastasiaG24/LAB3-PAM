import 'dart:async';

import 'package:fitness_lab2/data/fitness_repository.dart';
import 'package:fitness_lab2/models/featured_plan.dart';
import 'package:fitness_lab2/models/gym.dart';
import 'package:fitness_lab2/models/gym_details.dart';
import 'package:fitness_lab2/models/home_header.dart';
import 'package:fitness_lab2/models/home_page_data.dart';
import 'package:fitness_lab2/models/pricing.dart';
import 'package:fitness_lab2/models/program_filter.dart';
import 'package:fitness_lab2/models/todays_challenge.dart';
import 'package:fitness_lab2/models/workout_program.dart';

const yoga = WorkoutProgram(
  id: 'p1',
  title: 'Yoga',
  imageUrl: 'https://example.com/yoga.jpg',
  calories: 210,
  durationMinutes: 120,
);

const arms = WorkoutProgram(
  id: 'p2',
  title: 'Arm Strengthening',
  imageUrl: 'https://example.com/arms.jpg',
  calories: 210,
  durationMinutes: 120,
  isPro: true,
);

const cardio = WorkoutProgram(
  id: 'p3',
  title: 'Cardio Training',
  imageUrl: 'https://example.com/cardio.jpg',
  calories: 260,
  durationMinutes: 45,
);

const filters = [
  ProgramFilter(id: 'all', name: 'All Type', selected: true),
  ProgramFilter(id: 'pilates', name: 'Pilates'),
  ProgramFilter(id: 'cardio', name: 'Cardio'),
  ProgramFilter(id: 'yoga', name: 'Yoga'),
];

HomePageData homeData({
  List<WorkoutProgram> programs = const [yoga, arms, cardio],
}) {
  return HomePageData(
    header: const HomeHeader(
      date: 'Friday, 20 May',
      greeting: 'Good Morning',
      hasUnreadNotifications: true,
    ),
    challenge: const TodaysChallenge(
      title: "Today's Challenge",
      activity: 'Running',
      completed: 15,
      total: 20,
    ),
    featuredPlans: const [
      FeaturedPlan(
        id: 'f1',
        title: 'Massive Upper Body',
        imageUrl: 'https://example.com/featured.jpg',
        duration: '5 week',
        frequency: '4x/week',
        actionLabel: 'Start Now',
      ),
    ],
    filters: filters,
    programs: programs,
  );
}

const gymDetails = GymDetails(
  gym: Gym(
    id: 'g1',
    name: 'Mid City Gym Training',
    location: 'California, New York',
    heroImageUrl: 'https://example.com/gym.jpg',
    rating: 4.5,
    reviewCount: 1232,
    description: 'Description',
    amenities: [],
    pricing: Pricing(
      amount: 69,
      currency: 'USD',
      period: 'week',
      formatted: r'$69.00 /week',
    ),
  ),
  reserveLabel: 'Reserve',
  reserveEnabled: true,
);

class FakeFitnessRepository implements FitnessRepository {
  FakeFitnessRepository({HomePageData? home, this.failures = 0})
    : home = home ?? homeData();

  HomePageData home;
  int failures;
  int homeCalls = 0;
  Completer<void>? gate;

  @override
  Future<HomePageData> fetchHomePage() async {
    homeCalls++;
    await gate?.future;
    if (failures > 0) {
      failures--;
      throw const FormatException('broken json');
    }
    return home;
  }

  @override
  Future<GymDetails> fetchGymDetails() async {
    if (failures > 0) {
      failures--;
      throw const FormatException('broken json');
    }
    return gymDetails;
  }
}
