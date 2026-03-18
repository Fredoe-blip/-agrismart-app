import 'package:flutter_test/flutter_test.dart';
import 'package:AgriSmart/main.dart';

void main() {
  testWidgets('AgriSmart démarre sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriSmartApp());
    expect(find.text('AgriSmart'), findsOneWidget);
  });
}