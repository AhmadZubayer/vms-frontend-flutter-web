import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../domain/vehicle.dart';
import 'status_chip.dart';

/// What the row menu was asked to do.
enum VehicleRowAction { update, delete }

/// The vehicle list, one row per vehicle, with a row menu on the right.
class VehiclesTable extends StatelessWidget {
  const VehiclesTable({
    super.key,
    required this.vehicles,
    required this.onAction,
  });

  final List<Vehicle> vehicles;
  final void Function(Vehicle vehicle, VehicleRowAction action) onAction;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width < 900 ? 900 : 0,
          ),
          child: DataTable(
            columnSpacing: 28,
            headingRowHeight: 48,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            columns: const <DataColumn>[
              DataColumn(label: Text('Vehicle number')),
              DataColumn(label: Text('Brand')),
              DataColumn(label: Text('Company')),
              DataColumn(label: Text('Model')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: <DataRow>[
              for (final Vehicle vehicle in vehicles)
                DataRow(
                  key: ValueKey<int>(vehicle.id),
                  cells: <DataCell>[
                    DataCell(Text(vehicle.vehicleNumber)),
                    DataCell(Text(vehicle.brand)),
                    DataCell(Text(vehicle.company)),
                    DataCell(Text(vehicle.model)),
                    DataCell(Text(vehicle.typeLabel)),
                    DataCell(StatusChip(label: vehicle.statusLabel)),
                    DataCell(
                      _RowMenu(
                        vehicle: vehicle,
                        onAction: (VehicleRowAction action) =>
                            onAction(vehicle, action),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({required this.vehicle, required this.onAction});

  final Vehicle vehicle;
  final ValueChanged<VehicleRowAction> onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VehicleRowAction>(
      prefix: const Icon(FLucideIcons.ellipsisVertical),
      semanticsLabel: 'Actions for ${vehicle.vehicleNumber}',
      onSelected: onAction,
      itemBuilder: (BuildContext context) =>
          const <PopupMenuEntry<VehicleRowAction>>[
            PopupMenuItem<VehicleRowAction>(
              value: VehicleRowAction.update,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(FLucideIcons.pencil),
                title: Text('Update'),
              ),
            ),
            PopupMenuItem<VehicleRowAction>(
              value: VehicleRowAction.delete,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(FLucideIcons.trash2),
                title: Text('Delete'),
              ),
            ),
          ],
    );
  }
}
