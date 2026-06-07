import 'package:flutter_test/flutter_test.dart';
import 'package:agri_helper/main.dart';

void main() {
  testWidgets('App launches and displays welcome text',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AgriHelperApp());

    // Verify the welcome text is found
    expect(find.text('Welcome, Farmer!'), findsOneWidget);

    // Verify the app title is present in app bar
    expect(find.text('AgriHelper'), findsOneWidget);

    // Verify quick access cards exist
    expect(find.text('Government Schemes'), findsOneWidget);
    expect(find.text('Farming Practices'), findsOneWidget);
    expect(find.text('Market Prices'), findsOneWidget);
    expect(find.text('Expert Help'), findsOneWidget);
  });
}
