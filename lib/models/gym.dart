import 'package:equatable/equatable.dart';

import 'amenity.dart';
import 'pricing.dart';

class Gym extends Equatable {
  const Gym({
    required this.id,
    required this.name,
    required this.location,
    required this.heroImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
    required this.pricing,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      heroImageUrl: json['heroImageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      description: json['description'] as String,
      amenities: (json['amenities'] as List<dynamic>)
          .map((item) => Amenity.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      pricing: Pricing.fromJson(json['pricing'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String name;
  final String location;
  final String heroImageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<Amenity> amenities;
  final Pricing pricing;

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    heroImageUrl,
    rating,
    reviewCount,
    description,
    amenities,
    pricing,
  ];
}
