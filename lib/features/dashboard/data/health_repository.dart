import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/server_health.dart';

final Provider<HealthRepository> healthRepositoryProvider =
    Provider<HealthRepository>(
      (Ref ref) => HealthRepository(ref.watch(apiClientProvider)),
    );

/// Asks the API whether it is running and whether its database answers.
class HealthRepository {
  const HealthRepository(this._api);

  final ApiClient _api;

  Future<ServerHealth> fetch() async {
    final dynamic payload = await _api.get('/api/health');
    return ServerHealth.fromJson(Map<String, dynamic>.from(payload as Map));
  }
}

/// The current server health. Refresh it with `ref.invalidate(serverHealthProvider)`.
final FutureProvider<ServerHealth> serverHealthProvider =
    FutureProvider<ServerHealth>(
      (Ref ref) => ref.watch(healthRepositoryProvider).fetch(),
    );
