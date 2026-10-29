import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myhospital/widgets/mobile_bottom_navigation.dart';

void main() {
  testWidgets('mobile bottom bar displays all navigation actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: MobileBottomNavigation(
            onScanQr: _noop,
            onFamily: _noop,
            onBloodBank: _noop,
            onDocuments: _noop,
            onHistory: _noop,
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Emergency options',
            onPressed: _noop,
            child: const Icon(Icons.add_rounded),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    final bottomIcons = [
      Icons.qr_code_scanner_rounded,
      Icons.people_outline_rounded,
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
      expect(iconRect.bottom, lessThanOrEqualTo(844));
    }
    expect(find.byTooltip('Emergency options'), findsOneWidget);
  });
}

void _noop() {}
