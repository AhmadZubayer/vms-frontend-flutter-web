import 'vehicle_status.dart';
import 'vehicle_type.dart';

/// A vehicle in the registry.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.brand,
    required this.company,
    required this.model,
    required this.type,
    required this.status,
  });

  final int id;
  final String vehicleNumber;
  final String brand;
  final String company;
  final String model;

  /// Raw API value, so an unknown entry still renders.
  final String type;

  /// Raw API value, so an unknown entry still renders.
  final String status;

  String get typeLabel => VehicleType.labelOf(type);

  String get statusLabel => VehicleStatus.labelOf(status);

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: (json['id'] as num).toInt(),
    vehicleNumber: (json['vehicleNumber'] as String?) ?? '',
    brand: (json['brand'] as String?) ?? '',
    company: (json['company'] as String?) ?? '',
    model: (json['model'] as String?) ?? '',
    type: (json['type'] as String?) ?? '',
    status: (json['status'] as String?) ?? '',
  );
}

/// The six fields the API takes when registering or replacing a vehicle.
class VehicleDraft {
  const VehicleDraft({
    required this.vehicleNumber,
    required this.brand,
    required this.company,
    required this.model,
    required this.type,
    required this.status,
  });

  final String vehicleNumber;
  final String brand;
  final String company;
  final String model;
  final VehicleType type;
  final VehicleStatus status;

  Map<String, String> toJson() => <String, String>{
    'vehicleNumber': vehicleNumber,
    'brand': brand,
    'company': company,
    'model': model,
    'type': type.wireName,
    'status': status.wireName,
  };
}
