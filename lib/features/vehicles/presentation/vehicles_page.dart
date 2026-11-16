import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/responsive_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/paged_result.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import 'vehicles_controller.dart';
import 'widgets/pagination_bar.dart';
import 'widgets/vehicle_form_sheet.dart';
import 'widgets/vehicles_table.dart';

/// The vehicle registry: search, filter, page, and the four write actions.
class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  static const Duration _searchDelay = Duration(milliseconds: 350);
  static const double _wideHeaderBreakpoint = 1120;

  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  /// Guards against a second row action while one is still on screen.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _search.text = ref.read(vehicleQueryProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Waits for a pause in typing before asking the API again.
  void _onSearchChanged(String term) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (mounted) {
        ref.read(vehicleQueryProvider.notifier).search(term);
      }
    });
  }

  Future<void> _openForm({Vehicle? vehicle}) async {
    if (_busy) {
      return;
    }
    _busy = true;

    final bool? saved = await showResponsiveSheet<bool>(
      context: context,
      builder: (BuildContext _) => VehicleFormSheet(vehicle: vehicle),
    );
    _busy = false;

    if (saved == true && mounted) {
      AppToast.success(
        context,
        vehicle == null
            ? 'Vehicle added to the registry.'
            : 'Vehicle ${vehicle.vehicleNumber} updated.',
      );
    }
  }

  Future<void> _confirmDelete(Vehicle vehicle) async {
    if (_busy) {
      return;
    }
    _busy = true;

    // Let the row menu finish closing before the dialog takes the screen.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) {
      _busy = false;
      return;
    }

    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete this vehicle?',
      message:
          'Vehicle ${vehicle.vehicleNumber} will be removed from the registry. '
          'This cannot be undone.',
    );
    _busy = false;
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await ref.deleteVehicle(vehicle.id);
      if (mounted) {
        AppToast.success(context, 'Vehicle ${vehicle.vehicleNumber} deleted.');
      }
    } on ApiException catch (error) {
      if (mounted) {
        AppToast.error(context, error.message);
      }
    } on Object {
      if (mounted) {
        AppToast.error(context, 'The vehicle could not be deleted.');
      }
    }
  }

  void _handleRowAction(Vehicle vehicle, VehicleRowAction action) {
    switch (action) {
      case VehicleRowAction.update:
        _openForm(vehicle: vehicle);
      case VehicleRowAction.delete:
        _confirmDelete(vehicle);
    }
  }

  /// Deleting the last row of the last page leaves the pager past the end.
  void _stepBackIfPastEnd(PagedResult<Vehicle> page, VehicleQuery query) {
    if (page.isEmpty && page.totalItems > 0 && query.page > 0) {
      final int lastPage = page.totalPages == 0 ? 0 : page.totalPages - 1;
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          ref.read(vehicleQueryProvider.notifier).goToPage(lastPage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final VehicleQuery query = ref.watch(vehicleQueryProvider);
    final AsyncValue<PagedResult<Vehicle>> vehicles = ref.watch(
      vehiclesPageProvider,
    );

    final PagedResult<Vehicle>? loaded = vehicles.value;
    if (loaded != null) {
      _stepBackIfPastEnd(loaded, query);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= _wideHeaderBreakpoint;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: _Header(
                wide: wide,
                count: loaded?.totalItems,
                searchController: _search,
                status: query.status,
                onSearchChanged: _onSearchChanged,
                onStatusChanged: (VehicleStatus? status) => ref
                    .read(vehicleQueryProvider.notifier)
                    .filterByStatus(status),
                onAdd: () => _openForm(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: FCard(
                  child: vehicles.when(
                    loading: () => const LoadingView(),
                    error: (Object error, StackTrace _) => ErrorView(
                      message: error is ApiException
                          ? error.message
                          : 'The vehicle list could not be loaded.',
                      onRetry: () => ref.invalidate(vehiclesPageProvider),
                    ),
                    data: (PagedResult<Vehicle> page) => Column(
                      children: <Widget>[
                        Expanded(
                          child: page.isEmpty
                              ? EmptyView(
                                  icon: FLucideIcons.car,
                                  message:
                                      query.search.isEmpty &&
                                          query.status == null
                                      ? 'No vehicles registered yet.'
                                      : 'No vehicles match this search.',
                                )
                              : SingleChildScrollView(
                                  child: VehiclesTable(
                                    vehicles: page.items,
                                    onAction: _handleRowAction,
                                  ),
                                ),
                        ),
                        const FDivider(),
                        PaginationBar(
                          page: page,
                          pageSize: query.size,
                          onPageChanged: (int next) => ref
                              .read(vehicleQueryProvider.notifier)
                              .goToPage(next),
                          onPageSizeChanged: (int size) => ref
                              .read(vehicleQueryProvider.notifier)
                              .setPageSize(size),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.wide,
    required this.count,
    required this.searchController,
    required this.status,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onAdd,
  });

  final bool wide;
  final int? count;
  final TextEditingController searchController;
  final VehicleStatus? status;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VehicleStatus?> onStatusChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    // The button is pinned to the top right of the page in both layouts; the
    // title and count take whatever width is left.
    final Widget titleRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: wide
              ? Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Vehicles',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.display.xl2,
                      ),
                    ),
                    if (count != null) ...<Widget>[
                      const SizedBox(width: 10),
                      FBadge(
                        variant: FBadgeVariant.secondary,
                        child: Text('$count'),
                      ),
                    ],
                  ],
                )
              // The header bar already names the page on a narrow window.
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    count == null
                        ? 'Registered vehicles'
                        : '$count registered ${count == 1 ? 'vehicle' : 'vehicles'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        FButton(
          mainAxisSize: MainAxisSize.min,
          onPress: onAdd,
          prefix: const Icon(FLucideIcons.plus),
          child: Text(wide ? 'Add new vehicle' : 'Add'),
        ),
      ],
    );

    final Widget search = _SearchField(
      controller: searchController,
      onChanged: onSearchChanged,
    );

    final Widget filter = _StatusFilter(
      status: status,
      onChanged: onStatusChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        titleRow,
        const SizedBox(height: 16),
        if (wide)
          Row(
            children: <Widget>[
              Expanded(child: search),
              const SizedBox(width: 12),
              SizedBox(width: 210, child: filter),
            ],
          )
        else ...<Widget>[
          search,
          const SizedBox(height: 10),
          filter,
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => FTextField(
    control: FTextFieldControl.managed(
      controller: controller,
      onChange: (value) => onChanged(value.text),
    ),
    textInputAction: TextInputAction.search,
    hint: 'Search number, brand, company or model',
    prefixBuilder: (BuildContext context, _, _) => Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(
        FLucideIcons.search,
        size: 16,
        color: context.theme.colors.mutedForeground,
      ),
    ),
    clearable: (value) => value.text.isNotEmpty,
  );
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.status, required this.onChanged});

  static const String _all = '';

  final VehicleStatus? status;
  final ValueChanged<VehicleStatus?> onChanged;

  @override
  Widget build(BuildContext context) => FSelect<String>(
    hint: 'All statuses',
    prefixBuilder: (BuildContext context, _, _) => Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(
        FLucideIcons.listFilter,
        size: 16,
        color: context.theme.colors.mutedForeground,
      ),
    ),
    items: <String, String>{
      'All statuses': _all,
      for (final VehicleStatus value in VehicleStatus.values)
        value.label: value.name,
    },
    control: FSelectControl.lifted(
      value: status?.name ?? _all,
      onChange: (String? value) => onChanged(VehicleStatus.tryParse(value)),
    ),
  );
}
