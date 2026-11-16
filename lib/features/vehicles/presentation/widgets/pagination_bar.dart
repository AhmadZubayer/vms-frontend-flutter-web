import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../domain/paged_result.dart';
import '../../domain/vehicle.dart';
import '../vehicles_controller.dart';

/// Page controls under the vehicle list.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final PagedResult<Vehicle> page;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final int lastPage = page.totalPages == 0 ? 0 : page.totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        spacing: 16,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Rows per page', style: theme.typography.body.sm),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: FSelect<int>(
                  items: {
                    for (final size in VehicleQuery.pageSizes) '$size': size,
                  },
                  control: FSelectControl.lifted(
                    value: pageSize,
                    onChange: (value) {
                      if (value != null && value != pageSize) {
                        onPageSizeChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: <Widget>[
              Text(
                page.totalItems == 0
                    ? 'No vehicles'
                    : '${page.firstItemIndex}–${page.lastItemIndex} of ${page.totalItems}',
                style: theme.typography.body.sm,
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: 'First page',
                    onPress: page.hasPrevious ? () => onPageChanged(0) : null,
                    child: const Icon(FLucideIcons.chevronsLeft),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: 'Previous page',
                    onPress: page.hasPrevious
                        ? () => onPageChanged(page.pageNumber - 1)
                        : null,
                    child: const Icon(FLucideIcons.chevronLeft),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: 'Next page',
                    onPress: page.hasNext
                        ? () => onPageChanged(page.pageNumber + 1)
                        : null,
                    child: const Icon(FLucideIcons.chevronRight),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: 'Last page',
                    onPress: page.hasNext
                        ? () => onPageChanged(lastPage)
                        : null,
                    child: const Icon(FLucideIcons.chevronsRight),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
