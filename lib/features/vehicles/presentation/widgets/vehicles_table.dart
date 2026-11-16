import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../domain/vehicle.dart';
import 'status_chip.dart';

enum VehicleRowAction { update, delete }

/// The vehicle list: a table on a wide window, stacked cards on a narrow one,
/// so nothing has to be scrolled sideways to be read.
class VehiclesTable extends StatelessWidget {
  const VehiclesTable({
    super.key,
    required this.vehicles,
    required this.onAction,
  });

  /// Below this width the rows are drawn as cards instead of table rows.
  static const double _tableBreakpoint = 820;

  final List<Vehicle> vehicles;
  final void Function(Vehicle vehicle, VehicleRowAction action) onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return constraints.maxWidth < _tableBreakpoint
            ? _CardList(vehicles: vehicles, onAction: onAction)
            : _Table(vehicles: vehicles, onAction: onAction);
      },
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.vehicles, required this.onAction});

  final List<Vehicle> vehicles;
  final void Function(Vehicle vehicle, VehicleRowAction action) onAction;

  Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: child,
  );

  Widget _text(BuildContext context, String value, {bool strong = false}) =>
      Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1.3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(0.8),
        5: IntrinsicColumnWidth(),
        6: FixedColumnWidth(72),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.colors.border),
      ),
      children: <TableRow>[
        TableRow(
          decoration: BoxDecoration(color: theme.colors.muted),
          children: <Widget>[
            for (final String label in <String>[
              'Vehicle number',
              'Brand',
              'Company',
              'Model',
              'Type',
              'Status',
              '',
            ])
              _cell(
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
        for (final Vehicle vehicle in vehicles)
          TableRow(
            key: ValueKey<int>(vehicle.id),
            children: <Widget>[
              _cell(_text(context, vehicle.vehicleNumber, strong: true)),
              _cell(_text(context, vehicle.brand)),
              _cell(_text(context, vehicle.company)),
              _cell(_text(context, vehicle.model)),
              _cell(_text(context, vehicle.typeLabel)),
              _cell(
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(label: vehicle.statusLabel),
                ),
              ),
              _cell(RowMenu(vehicle: vehicle, onAction: onAction)),
            ],
          ),
      ],
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.vehicles, required this.onAction});

  final List<Vehicle> vehicles;
  final void Function(Vehicle vehicle, VehicleRowAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Column(
      children: <Widget>[
        for (final Vehicle vehicle in vehicles)
          Container(
            key: ValueKey<int>(vehicle.id),
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              vehicle.vehicleNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(label: vehicle.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.brand} ${vehicle.model} · ${vehicle.typeLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm,
                      ),
                      Text(
                        vehicle.company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                RowMenu(vehicle: vehicle, onAction: onAction),
              ],
            ),
          ),
      ],
    );
  }
}

/// The three-dot menu that offers Update and Delete for one vehicle.
class RowMenu extends StatelessWidget {
  const RowMenu({super.key, required this.vehicle, required this.onAction});

  final Vehicle vehicle;
  final void Function(Vehicle vehicle, VehicleRowAction action) onAction;

  @override
  Widget build(BuildContext context) {
    return FPopoverMenu(
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menuBuilder: (BuildContext context, FPopoverController controller, _) =>
          [
            FItemGroup(
              children: [
                FItem(
                  prefix: const Icon(FLucideIcons.pencil),
                  title: const Text('Update'),
                  onPress: () async {
                    await controller.hide();
                    onAction(vehicle, VehicleRowAction.update);
                  },
                ),
                FItem(
                  variant: FItemVariant.destructive,
                  prefix: const Icon(FLucideIcons.trash2),
                  title: const Text('Delete'),
                  onPress: () async {
                    await controller.hide();
                    onAction(vehicle, VehicleRowAction.delete);
                  },
                ),
              ],
            ),
          ],
      builder: (BuildContext context, FPopoverController controller, _) =>
          FButton.icon(
            variant: FButtonVariant.ghost,
            semanticsLabel: 'Actions for ${vehicle.vehicleNumber}',
            onPress: controller.toggle,
            child: const Icon(FLucideIcons.ellipsisVertical),
          ),
    );
  }
}
