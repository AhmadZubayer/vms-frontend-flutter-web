/// The statuses the API accepts for a vehicle.
enum VehicleStatus {
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive'),
  maintenance('MAINTENANCE', 'Maintenance'),
  retired('RETIRED', 'Retired');

  const VehicleStatus(this.wireName, this.label);

  /// Value sent to and read from the API.
  final String wireName;

  /// Value shown to the person.
  final String label;

  static VehicleStatus? tryParse(String? value) {
    if (value == null) {
      return null;
    }

    final String wanted = value.trim().toUpperCase();
    for (final VehicleStatus status in VehicleStatus.values) {
      if (status.wireName == wanted) {
        return status;
      }
    }
    return null;
  }

  /// Falls back to the raw value when the API adds a status this build
  /// does not know about yet.
  static String labelOf(String wireName) =>
      tryParse(wireName)?.label ?? wireName;
}
