/// What `GET /api/health` reports about the server and its database.
class ServerHealth {
  const ServerHealth({
    required this.status,
    required this.databaseConnected,
    required this.database,
  });

  /// `UP` when the server answered at all.
  final String status;

  final bool databaseConnected;

  /// `CONNECTED` or `DISCONNECTED`, as the server words it.
  final String database;

  bool get serverUp => status.toUpperCase() == 'UP';

  factory ServerHealth.fromJson(Map<String, dynamic> json) => ServerHealth(
    status: (json['status'] as String?) ?? 'UNKNOWN',
    databaseConnected: (json['databaseConnected'] as bool?) ?? false,
    database: (json['database'] as String?) ?? 'UNKNOWN',
  );
}
