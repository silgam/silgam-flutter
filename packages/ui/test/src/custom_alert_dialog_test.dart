import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  group('CustomAlertDialog', () {
    testWidgets('renders without parameters', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CustomAlertDialog()));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders with title', (WidgetTester tester) async {
      const title = 'Test Title';

      await tester.pumpWidget(MaterialApp(home: CustomAlertDialog(title: title)));

      expect(find.text(title), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('renders with content', (WidgetTester tester) async {
      const content = 'Test Content';

      await tester.pumpWidget(MaterialApp(home: CustomAlertDialog(content: content)));

      expect(find.text(content), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('renders action buttons', (WidgetTester tester) async {
      final actions = [
        TextButton(onPressed: () {}, child: const Text('OK')),
        TextButton(onPressed: () {}, child: const Text('Cancel')),
      ];

      await tester.pumpWidget(MaterialApp(home: CustomAlertDialog(actions: actions)));

      expect(find.byType(TextButton), findsNWidgets(2));
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('scrollable parameter is respected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CustomAlertDialog(scrollable: true, content: 'Test Content')),
      );

      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.scrollable, isTrue);
    });

    testWidgets('renders correctly with all parameters', (WidgetTester tester) async {
      final actions = [TextButton(onPressed: () {}, child: const Text('OK'))];

      await tester.pumpWidget(
        MaterialApp(
          home: CustomAlertDialog(
            title: 'Test Title',
            content: 'Test Content',
            actions: actions,
            scrollable: true,
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.scrollable, isTrue);
    });

    testWidgets('renders with custom content widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomAlertDialog.customContent(
            title: 'Test Title',
            content: Text(
              'Custom Widget Content',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Custom Widget Content'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Custom Widget Content'));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
