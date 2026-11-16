import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vehicles_repository.dart';
import '../domain/paged_result.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_stats.dart';
import '../domain/vehicle_status.dart';

/// Which slice of the registry the vehicles page is showing.
class VehicleQuery {
  const VehicleQuery({
    this.page = 0,
    this.size = 10,
    this.search = '',
    this.status,
  });

  final int page;
  final int size;
  final String search;
  final VehicleStatus? status;

  static const List<int> pageSizes = <int>[10, 20, 50, 100];

  @override
  bool operator ==(Object other) =>
      other is VehicleQuery &&
      other.page == page &&
      other.size == size &&
      other.search == search &&
      other.status == status;

  @override
  int get hashCode => Object.hash(page, size, search, status);
}

final NotifierProvider<VehicleQueryController, VehicleQuery>
vehicleQueryProvider = NotifierProvider<VehicleQueryController, VehicleQuery>(
  VehicleQueryController.new,
);

/// Drives the search box, the status filter, and the pager.
class VehicleQueryController extends Notifier<VehicleQuery> {
  @override
  VehicleQuery build() => const VehicleQuery();

  /// A new search term starts again from the first page.
  void search(String term) => state = VehicleQuery(
    size: state.size,
    search: term,
    status: state.status,
  );

  void filterByStatus(VehicleStatus? status) => state = VehicleQuery(
    size: state.size,
    search: state.search,
    status: status,
  );

  void goToPage(int page) => state = VehicleQuery(
    page: page < 0 ? 0 : page,
    size: state.size,
    search: state.search,
    status: state.status,
  );

  void setPageSize(int size) => state = VehicleQuery(
    size: size,
    search: state.search,
    status: state.status,
  );
}

/// The page of vehicles that matches the current query.
final FutureProvider<PagedResult<Vehicle>> vehiclesPageProvider =
    FutureProvider<PagedResult<Vehicle>>((Ref ref) {
      final VehicleQuery query = ref.watch(vehicleQueryProvider);

      return ref
          .watch(vehiclesRepositoryProvider)
          .fetchPage(
            page: query.page,
            size: query.size,
            query: query.search,
            status: query.status,
          );
    });

/// Registry totals for the dashboard cards.
final FutureProvider<VehicleStats> vehicleStatsProvider =
    FutureProvider<VehicleStats>(
      (Ref ref) => ref.watch(vehiclesRepositoryProvider).fetchStats(),
    );

/// Writes to the registry from a widget, then reloads what reads it.
///
/// The reload is awaited, so by the time a form closes or a toast appears the
/// table and the dashboard totals already hold the new data.
extension VehicleWrites on WidgetRef {
  Future<void> createVehicle(VehicleDraft draft) async {
    await read(vehiclesRepositoryProvider).create(draft);
    await reloadVehicles();
  }

  Future<void> updateVehicle(int id, VehicleDraft draft) async {
    await read(vehiclesRepositoryProvider).update(id, draft);
    await reloadVehicles();
  }

  Future<void> deleteVehicle(int id) async {
    await read(vehiclesRepositoryProvider).delete(id);
    await reloadVehicles();
  }

  /// Re-reads the current page and the registry totals from the API.
  Future<void> reloadVehicles() async {
    invalidate(vehicleStatsProvider);
    // The awaited refetch is the point: the caller resumes with fresh data.
    // ignore: unused_result
    await refresh(vehiclesPageProvider.future);
  }
}
