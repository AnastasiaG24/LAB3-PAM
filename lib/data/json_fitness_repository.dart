import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/gym_details.dart';
import '../models/home_page_data.dart';
import 'app_assets.dart';
import 'fitness_repository.dart';

class JsonFitnessRepository implements FitnessRepository {
  JsonFitnessRepository({
    AssetBundle? bundle,
    this.assetPath = AppData.fitness,
    this.latency = const Duration(milliseconds: 800),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  final Duration latency;

  @override
  Future<HomePageData> fetchHomePage() async {
    final raw = await _readRaw();
    return compute(_parseHomePage, raw);
  }

  @override
  Future<GymDetails> fetchGymDetails() async {
    final raw = await _readRaw();
    return compute(_parseGymDetails, raw);
  }

  Future<String> _readRaw() async {
    await Future<void>.delayed(latency);
    return _bundle.loadString(assetPath, cache: false);
  }
}

HomePageData _parseHomePage(String raw) =>
    HomePageData.fromJson(_section(raw, 'fitnessHomePage'));

GymDetails _parseGymDetails(String raw) =>
    GymDetails.fromJson(_section(raw, 'fitnessGymDetailsPage'));

Map<String, dynamic> _section(String raw, String key) {
  final root = jsonDecode(raw) as Map<String, dynamic>;
  final section = root[key];
  if (section is! Map<String, dynamic>) {
    throw FormatException('Missing "$key" section');
  }
  return section;
}
