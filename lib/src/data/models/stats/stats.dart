import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

/// `GET /api/admin/stats/`. Money maps are currency code → minor units.
class AdminStats {
  final int days;
  final Map<String, int> users;
  final Map<String, int> goals;
  final List<Money> collected;
  final List<Money> collectedInPeriod;
  final List<Money> outstanding;
  final Map<String, int> payments;
  final int refundsOpen;
  final int refundsFailed;
  final List<Money> refundsOpenAmount;
  final int kycPending;
  final Map<String, int> bookings;
  final List<CollectionPoint> collectionsSeries;
  final List<CountPoint> signupsSeries;
  final List<TopItinerary> topItineraries;

  AdminStats({
    required this.days,
    required this.users,
    required this.goals,
    required this.collected,
    required this.collectedInPeriod,
    required this.outstanding,
    required this.payments,
    required this.refundsOpen,
    required this.refundsFailed,
    required this.refundsOpenAmount,
    required this.kycPending,
    required this.bookings,
    required this.collectionsSeries,
    required this.signupsSeries,
    required this.topItineraries,
  });

  static Map<String, int> _ints(dynamic json) => (json as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, (v as num).toInt()));

  static List<Money> _money(dynamic json) {
    final entries = _ints(json).entries.toList()
      ..sort(
        (a, b) => Currency.fromCode(
          a.key,
        ).index.compareTo(Currency.fromCode(b.key).index),
      );
    return [for (final e in entries) Money(e.value, Currency.fromCode(e.key))];
  }

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final outstandingTotal = _ints(json['outstanding']);
    final outstandingPaid = _ints(json['outstanding_paid']);
    final refunds = json['refunds'] as Map<String, dynamic>;
    return AdminStats(
      days: (json['days'] as num).toInt(),
      users: _ints(json['users']),
      goals: _ints(json['goals']),
      collected: _money(json['collected']),
      collectedInPeriod: _money(json['collected_in_period']),
      outstanding: _money({
        for (final e in outstandingTotal.entries)
          e.key: e.value - (outstandingPaid[e.key] ?? 0),
      }),
      payments: _ints(json['payments']),
      refundsOpen: (refunds['open'] as num).toInt(),
      refundsFailed: (refunds['failed'] as num).toInt(),
      refundsOpenAmount: _money(refunds['open_amount']),
      kycPending: (json['kyc_pending'] as num).toInt(),
      bookings: _ints(json['bookings']),
      collectionsSeries: (json['collections_series'] as List)
          .map((e) => CollectionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      signupsSeries: (json['signups_series'] as List)
          .map((e) => CountPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      topItineraries: (json['top_itineraries'] as List)
          .map((e) => TopItinerary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CollectionPoint {
  final DateTime date;
  final Money amount;
  final int count;

  CollectionPoint(this.date, this.amount, this.count);

  factory CollectionPoint.fromJson(Map<String, dynamic> json) =>
      CollectionPoint(
        DateTime.parse(json['date'] as String),
        Money(
          (json['amount'] as num).toInt(),
          Currency.fromCode(json['currency'] as String),
        ),
        (json['count'] as num).toInt(),
      );
}

class CountPoint {
  final DateTime date;
  final int count;

  CountPoint(this.date, this.count);

  factory CountPoint.fromJson(Map<String, dynamic> json) => CountPoint(
    DateTime.parse(json['date'] as String),
    (json['count'] as num).toInt(),
  );
}

class TopItinerary {
  final String uuid;
  final String title;
  final int goals;

  TopItinerary(this.uuid, this.title, this.goals);

  factory TopItinerary.fromJson(Map<String, dynamic> json) => TopItinerary(
    json['itinerary__uuid'].toString(),
    json['itinerary__title'] as String,
    (json['goals'] as num).toInt(),
  );
}
