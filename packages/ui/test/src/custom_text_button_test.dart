import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui/ui.dart';

abstract class VoidCallback {
  void call();
}

class MockVoidCallback extends Mock implements VoidCallback {}

void main() {
  group('CustomTextButton', () {
    late MockVoidCallback mockCallback;

    setUp(() {
      mockCallback = MockVoidCallback();
    });

    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomTextButton.primary(text: 'Button Text', onPressed: () {})),
      );

      expect(find.text('Button Text'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomTextButton.primary(text: 'Button', onPressed: mockCallback.call)),
      );

      verifyNever(() => mockCallback.call());

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      verify(() => mockCallback.call()).called(1);
    });

    testWidgets('primary variant uses default style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomTextButton.primary(text: 'Primary', onPressed: () {})),
      );

      final TextButton button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style, isNull);
    });

    testWidgets('secondary variant has grey foreground color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomTextButton.secondary(text: 'Secondary', onPressed: () {})),
      );

      final TextButton button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style?.foregroundColor?.resolve({}), Colors.grey.shade600);
    });

    testWidgets('destructive variant has red foreground color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomTextButton.destructive(text: 'Delete', onPressed: () {})),
      );

      final TextButton button = tester.widget<TextButton>(find.byType(TextButton));

      expect(button.style?.foregroundColor?.resolve({}), Colors.red);
    });
  });
}
