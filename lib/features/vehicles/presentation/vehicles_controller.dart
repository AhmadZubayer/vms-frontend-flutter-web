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

  void filterByStatus(VehicleStatus? status) =>
      state = VehicleQuery(size: state.size, search: state.search, status: status);

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

      return ref.watch(vehiclesRepositoryProvider).fetchPage(
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

final Provider<VehicleMutations> vehicleMutationsProvider =
    Provider<VehicleMutations>(VehicleMutations.new);

/// Writes to the registry, then refreshes everything that reads it.
class VehicleMutations {
  const VehicleMutations(this._ref);

  final Ref _ref;

  Future<void> create(VehicleDraft draft) async {
    await _ref.read(vehiclesRepositoryProvider).create(draft);
    _refresh();
  }

  Future<void> update(int id, VehicleDraft draft) async {
    await _ref.read(vehiclesRepositoryProvider).update(id, draft);
    _refresh();
  }

  Future<void> delete(int id) async {
    await _ref.read(vehiclesRepositoryProvider).delete(id);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(vehiclesPageProvider);
    _ref.invalidate(vehicleStatsProvider);
  }
}
