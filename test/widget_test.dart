import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('SubstackAuthApp loads welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SubstackAuthApp());

    // Verify welcome text is present
    expect(find.textContaining('Substack'), findsWidgets);
  });
}
