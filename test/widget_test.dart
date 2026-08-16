import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myhospital/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyHospitalApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
