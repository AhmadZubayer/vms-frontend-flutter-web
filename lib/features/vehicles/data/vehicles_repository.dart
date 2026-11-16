import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/paged_result.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_stats.dart';
import '../domain/vehicle_status.dart';

final Provider<VehiclesRepository> vehiclesRepositoryProvider =
    Provider<VehiclesRepository>(
      (Ref ref) => VehiclesRepository(ref.watch(apiClientProvider)),
    );

/// Reads and writes the vehicle registry.
class VehiclesRepository {
  const VehiclesRepository(this._api);

  static const String _path = '/api/vehicles';

  final ApiClient _api;

  /// Lists one page, narrowed by a free-text [query] and a [status] when given.
  Future<PagedResult<Vehicle>> fetchPage({
    int page = 0,
    int size = 10,
    String? query,
    VehicleStatus? status,
    String sort = 'id,desc',
  }) async {
    final String term = query?.trim() ?? '';

    final dynamic payload = await _api.get(
      _path,
      query: <String, dynamic>{
        'page': page,
        'size': size,
        'sort': sort,
        if (term.isNotEmpty) 'q': term,
        if (status != null) 'status': status.wireName,
      },
    );

    return PagedResult.fromJson<Vehicle>(
      Map<String, dynamic>.from(payload as Map),
      Vehicle.fromJson,
    );
  }

  Future<VehicleStats> fetchStats() async {
    final dynamic payload = await _api.get('$_path/stats');
    return VehicleStats.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<Vehicle> create(VehicleDraft draft) async {
    final dynamic payload = await _api.post(_path, body: draft.toJson());
    return Vehicle.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<Vehicle> update(int id, VehicleDraft draft) async {
    final dynamic payload = await _api.put('$_path/$id', body: draft.toJson());
    return Vehicle.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<void> delete(int id) => _api.delete('$_path/$id');
}
