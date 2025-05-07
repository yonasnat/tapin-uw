import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/main.dart';

void main() {
  testWidgets('App loads and shows TapIn@UW title', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify the title is displayed in an AppBar (or wherever you render it)
    expect(find.text('TapIn@UW'), findsOneWidget);
  });
}
