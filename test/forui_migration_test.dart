import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:vms_frontend_flutter/app/app.dart';
import 'package:vms_frontend_flutter/features/auth/domain/auth_state.dart';
import 'package:vms_frontend_flutter/features/auth/domain/auth_user.dart';
import 'package:vms_frontend_flutter/features/auth/presentation/auth_controller.dart';
import 'package:vms_frontend_flutter/features/dashboard/data/health_repository.dart';
import 'package:vms_frontend_flutter/features/dashboard/domain/server_health.dart';
import 'package:vms_frontend_flutter/features/vehicles/domain/paged_result.dart';
import 'package:vms_frontend_flutter/features/vehicles/domain/vehicle.dart';
import 'package:vms_frontend_flutter/features/vehicles/domain/vehicle_stats.dart';
import 'package:vms_frontend_flutter/features/vehicles/domain/vehicle_status.dart';
import 'package:vms_frontend_flutter/features/vehicles/presentation/vehicles_controller.dart';

class TestAuthController extends AuthController {
  TestAuthController({this.signedIn = true});
  final bool signedIn;

  @override
  AuthState build() => signedIn
      ? const AuthSignedIn(AuthUser(userEmail: 'operator@example.com'))
      : const AuthSignedOut();

  @override
  Future<void> signIn({
    required String userEmail,
    required String password,
  }) async {
    state = AuthSignedIn(AuthUser(userEmail: userEmail));
  }

  @override
  Future<void> signOut() async => state = const AuthSignedOut();
}

const vehicle = Vehicle(
  id: 1,
  vehicleNumber: 'DHAKA-1234',
  brand: 'Toyota',
  company: 'Stark',
  model: 'Corolla',
  type: 'SEDAN',
  status: 'ACTIVE',
);

Future<void> openApp(
  WidgetTester tester, {
  bool signedIn = true,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => TestAuthController(signedIn: signedIn),
        ),
        serverHealthProvider.overrideWith(
          (ref) async => const ServerHealth(
            status: 'UP',
            databaseConnected: true,
            database: 'CONNECTED',
          ),
        ),
        vehicleStatsProvider.overrideWith(
          (ref) async => const VehicleStats(total: 1, byStatus: {'ACTIVE': 1}),
        ),
        vehiclesPageProvider.overrideWith(
          (ref) async => const PagedResult(
            items: [vehicle],
            pageNumber: 0,
            pageSize: 10,
            totalItems: 1,
            totalPages: 1,
          ),
        ),
      ],
      child: const StarkVmsApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder button(String label) => find.byWidgetPredicate(
  (widget) => widget is FButton && widget.semanticsLabel == label,
);

void main() {
  testWidgets(
    'Forui login validates, signs in, and signs out through the app router',
    (tester) async {
      await openApp(tester, signedIn: false);
      expect(find.byType(EditableText), findsNWidgets(2));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your user email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      await tester.enterText(
        find.byType(EditableText).at(0),
        'operator@example.com',
      );
      await tester.enterText(find.byType(EditableText).at(1), 'password');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Total vehicles'), findsOneWidget);
      expect(find.byType(FSidebar), findsOneWidget);
      await tester.tap(button('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
    },
  );

  testWidgets(
    'Forui vehicle controls preserve search, filtering, forms, and delete cancellation',
    (tester) async {
      await openApp(tester);
      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();
      expect(find.text('DHAKA-1234'), findsOneWidget);
      await tester.enterText(find.byType(EditableText).first, 'Toyota');
      await tester.pump(const Duration(milliseconds: 400));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FScaffold).first),
      );
      expect(container.read(vehicleQueryProvider).search, 'Toyota');
      await tester.tap(find.text('All statuses').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maintenance').last);
      await tester.pumpAndSettle();
      expect(
        container.read(vehicleQueryProvider).status,
        VehicleStatus.maintenance,
      );
      await tester.tap(button('Actions for DHAKA-1234'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
      expect(find.text('Update vehicle'), findsOneWidget);
      expect(find.byType(FTextFormField), findsNWidgets(4));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(button('Actions for DHAKA-1234'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(FDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(FDialog), findsNothing);
      await tester.tap(find.text('Add new vehicle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add vehicle'));
      await tester.pumpAndSettle();
      expect(find.text('Enter the vehicle number'), findsOneWidget);
    },
  );

  testWidgets('Forui mobile navigation and vehicle form fit the viewport', (
    tester,
  ) async {
    await openApp(tester, size: const Size(390, 844));
    await tester.tap(button('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vehicles'));
    await tester.pumpAndSettle();
    expect(find.text('DHAKA-1234'), findsOneWidget);
    await tester.tap(find.text('Add new vehicle'));
    await tester.pumpAndSettle();
    expect(find.byType(FTextFormField), findsNWidgets(4));
    await tester.tap(button('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(FTextFormField), findsNothing);
  });
}
