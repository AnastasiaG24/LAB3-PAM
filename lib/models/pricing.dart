import 'package:equatable/equatable.dart';

class Pricing extends Equatable {
  const Pricing({
    required this.amount,
    required this.currency,
    required this.period,
    required this.formatted,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      period: json['period'] as String,
      formatted: json['formatted'] as String,
    );
  }

  final double amount;
  final String currency;
  final String period;
  final String formatted;

  String get periodLabel => '/$period';

  String get amountLabel => formatted.replaceAll(periodLabel, '').trim();

  @override
  List<Object?> get props => [amount, currency, period, formatted];
}
