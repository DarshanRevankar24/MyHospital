import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myhospital/screens/dashboard_screen.dart';
import 'package:myhospital/widgets/mobile_bottom_navigation.dart';

void main() {
  testWidgets('wide dashboard keeps the bottom bar visible', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomAppBar),
        matching: find.byIcon(Icons.home_outlined),
      ),
      findsOneWidget,
    );
  });

  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('bottom bar is visible at ${size.width}px width', (
      tester,
    ) async {
      var emergencyTapped = false;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: MobileBottomNavigation(
              onHome: _noop,
              onScanQr: _noop,
              onFamily: _noop,
              onEmergency: () => emergencyTapped = true,
              onBloodBank: _noop,
              onDocuments: _noop,
              onHistory: _noop,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      final bottomIcons = [
        Icons.home_outlined,
        Icons.qr_code_scanner_outlined,
        Icons.people_outline_rounded,
        Icons.add_rounded,
        Icons.bloodtype_outlined,
        Icons.description_outlined,
        Icons.history_rounded,
      ];
      for (final icon in bottomIcons) {
        final finder = find.descendant(
          of: find.byType(BottomAppBar),
          matching: find.byIcon(icon),
        );
        expect(finder, findsOneWidget);
        final iconRect = tester.getRect(finder);
        expect(iconRect.width, greaterThan(0));
        expect(iconRect.height, greaterThan(0));
        expect(iconRect.bottom, lessThanOrEqualTo(size.height));
      }
      await tester.tap(find.byTooltip('Emergency options'));
      expect(emergencyTapped, isTrue);
    });
  }
}

void _noop() {}
