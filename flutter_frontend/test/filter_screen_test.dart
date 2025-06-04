import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/filter_screen.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTesting();
  });

  testWidgets('FilterScreen has correct UI elements', (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(const TestWrapper(child: FilterScreen()));
    await tester.pumpAndSettle(); // Wait for any animations to complete

    // Verify that the app bar title is correct
    expect(find.text('Filter'), findsOneWidget);

    // Verify that all filter options are present
    expect(find.text('Computer Science Major'), findsOneWidget);
    expect(find.text('Engineering Major'), findsOneWidget);
    expect(find.text('Business Major'), findsOneWidget);
    expect(find.text('Basketball Player'), findsOneWidget);
    expect(find.text('Rockclimber'), findsOneWidget);
    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Gamer'), findsOneWidget);

    // Verify that all checkboxes are present and initially unchecked
    final checkboxes = find.byType(CheckboxListTile);
    expect(checkboxes, findsNWidgets(7)); // 7 filter options

    // Verify that Cancel and Save buttons are present
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Test checkbox interaction
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    
    // Verify the checkbox state changed
    final firstCheckbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).first);
    expect(firstCheckbox.value, isTrue);
  });
} 