/// The vehicle types the API accepts.
enum VehicleType {
  car('CAR', 'Car'),
  sedan('SEDAN', 'Sedan'),
  suv('SUV', 'SUV'),
  hatchback('HATCHBACK', 'Hatchback'),
  pickup('PICKUP', 'Pickup'),
  van('VAN', 'Van'),
  bus('BUS', 'Bus'),
  truck('TRUCK', 'Truck'),
  motorcycle('MOTORCYCLE', 'Motorcycle'),
  other('OTHER', 'Other');

  const VehicleType(this.wireName, this.label);

  /// Value sent to and read from the API.
  final String wireName;

  /// Value shown to the person.
  final String label;

  static VehicleType? tryParse(String? value) {
    if (value == null) {
      return null;
    }

    final String wanted = value.trim().toUpperCase();
    for (final VehicleType type in VehicleType.values) {
      if (type.wireName == wanted) {
        return type;
      }
    }
    return null;
  }

  /// Falls back to the raw value when the API adds a type this build does
  /// not know about yet.
  static String labelOf(String wireName) =>
      tryParse(wireName)?.label ?? wireName;
}
