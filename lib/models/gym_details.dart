import 'package:equatable/equatable.dart';

import 'gym.dart';

class GymDetails extends Equatable {
  const GymDetails({
    required this.gym,
    required this.reserveLabel,
    required this.reserveEnabled,
  });

  factory GymDetails.fromJson(Map<String, dynamic> json) {
    final actions = json['actions'] as Map<String, dynamic>;
    final reserve = actions['reserve'] as Map<String, dynamic>;
    return GymDetails(
      gym: Gym.fromJson(json['gym'] as Map<String, dynamic>),
      reserveLabel: reserve['label'] as String,
      reserveEnabled: reserve['enabled'] as bool? ?? true,
    );
  }

  final Gym gym;
  final String reserveLabel;
  final bool reserveEnabled;

  @override
  List<Object?> get props => [gym, reserveLabel, reserveEnabled];
}
