// subscription_model.dart
class Subscription {
  final DateTime startDate;
  final DateTime endDate;
  final int durationMonths;
  final double amount;
  final String transactionId;
  final String status; // 'active', 'expired', 'pending'

  Subscription({
    required this.startDate,
    required this.endDate,
    required this.durationMonths,
    required this.amount,
    required this.transactionId,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      durationMonths: json['durationMonths'],
      amount: json['amount'].toDouble(),
      transactionId: json['transactionId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'durationMonths': durationMonths,
      'amount': amount,
      'transactionId': transactionId,
      'status': status,
    };
  }

  bool get isActive => DateTime.now().isBefore(endDate) && status == 'active';
}
