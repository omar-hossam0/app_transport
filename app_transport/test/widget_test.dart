// Basic smoke test for App Transport
import 'package:flutter_test/flutter_test.dart';
import 'package:app_transport/main.dart';

void main() {
  testWidgets('MyApp renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Verify the splash screen shows the Explore button
    expect(find.text('Explore'), findsOneWidget);
  });
}
