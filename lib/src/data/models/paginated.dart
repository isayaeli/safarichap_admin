/// One page of a DRF list (`AdminPagination`): `count` plus `results`.
class Paginated<T> {
  final int count;
  final List<T> results;

  const Paginated({required this.count, required this.results});

  const Paginated.empty() : count = 0, results = const [];

  factory Paginated.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Unpaginated endpoints (roles, refund policies) return a bare list.
    if (json is List) {
      final items = json
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
      return Paginated(count: items.length, results: items);
    }
    final map = json as Map<String, dynamic>;
    return Paginated(
      count: (map['count'] as num).toInt(),
      results: (map['results'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
