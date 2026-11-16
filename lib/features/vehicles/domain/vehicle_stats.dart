import 'vehicle_status.dart';

/// How many vehicles are registered, and how they split across the statuses.
class VehicleStats {
  const VehicleStats({required this.total, required this.byStatus});

  final int total;

  /// Raw API status value to its count, including the statuses at zero.
  final Map<String, int> byStatus;

  int countOf(VehicleStatus status) => byStatus[status.wireName] ?? 0;

  factory VehicleStats.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> raw = Map<String, dynamic>.from(
      (json['byStatus'] as Map?) ?? <String, dynamic>{},
    );

    return VehicleStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byStatus: <String, int>{
        for (final MapEntry<String, dynamic> entry in raw.entries)
          entry.key: (entry.value as num?)?.toInt() ?? 0,
      },
    );
  }
}
