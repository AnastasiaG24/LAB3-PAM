import 'package:equatable/equatable.dart';

class HomeHeader extends Equatable {
  const HomeHeader({
    required this.date,
    required this.greeting,
    required this.hasUnreadNotifications,
  });

  factory HomeHeader.fromJson(Map<String, dynamic> json) {
    final notification = json['notification'] as Map<String, dynamic>?;
    return HomeHeader(
      date: json['date'] as String,
      greeting: json['greeting'] as String,
      hasUnreadNotifications: notification?['hasUnread'] as bool? ?? false,
    );
  }

  final String date;
  final String greeting;
  final bool hasUnreadNotifications;

  @override
  List<Object?> get props => [date, greeting, hasUnreadNotifications];
}
