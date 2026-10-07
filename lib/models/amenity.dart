import 'package:equatable/equatable.dart';

class Amenity extends Equatable {
  const Amenity({required this.id, required this.name, required this.iconUrl});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
    );
  }

  final String id;
  final String name;
  final String iconUrl;

  @override
  List<Object?> get props => [id, name, iconUrl];
}
