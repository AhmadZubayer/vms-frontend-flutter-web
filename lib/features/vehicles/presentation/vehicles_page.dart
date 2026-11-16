import 'dart:async';

import 'package:flutter/widgets.dart';
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
    final bool? saved = await showResponsiveSheet<bool>(
      context: context,
      builder: (BuildContext _) => VehicleFormSheet(vehicle: vehicle),
    );

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
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete this vehicle?',
      message:
          'Vehicle ${vehicle.vehicleNumber} will be removed from the registry. '
          'This cannot be undone.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await ref.read(vehicleMutationsProvider).delete(vehicle.id);
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
                                  message: query.search.isEmpty &&
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

    final Widget title = Text(
      count == null ? 'Vehicles' : 'Vehicles ($count)',
      style: theme.typography.display.xl2,
    );

    final Widget search = _SearchField(
      controller: searchController,
      onChanged: onSearchChanged,
    );

    final Widget filter = _StatusFilter(
      status: status,
      onChanged: onStatusChanged,
    );

    final Widget addButton = FButton(mainAxisSize: MainAxisSize.min,
      onPress: onAdd,
      prefix: const Icon(FLucideIcons.plus),
      label: const Text('Add new vehicle'),
    );

    if (wide) {
      return Row(
        children: <Widget>[
          title,
          const SizedBox(width: 24),
          SizedBox(width: 320, child: search),
          const SizedBox(width: 12),
          SizedBox(width: 200, child: filter),
          const Spacer(),
          addButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: title),
            const SizedBox(width: 12),
            addButton,
          ],
        ),
        const SizedBox(height: 16),
        search,
        const SizedBox(height: 12),
        filter,
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search number, brand, company, model',
        isDense: true,
        prefixIcon: const Icon(FLucideIcons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, Widget? _) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return FButton.icon(variant: FButtonVariant.ghost,
              semanticsLabel: 'Clear search',
              prefix: const Icon(FLucideIcons.x),
              onPress: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.status, required this.onChanged});

  final VehicleStatus? status;
  final ValueChanged<VehicleStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<VehicleStatus?>(
      initialValue: status,
      isDense: true,
      decoration: const InputDecoration(labelText: 'Status', isDense: true),
      items: <DropdownMenuItem<VehicleStatus?>>[
        const DropdownMenuItem<VehicleStatus?>(child: Text('All statuses')),
        for (final VehicleStatus value in VehicleStatus.values)
          DropdownMenuItem<VehicleStatus?>(
            value: value,
            child: Text(value.label),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
