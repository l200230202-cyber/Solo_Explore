import 'package:flutter_test/flutter_test.dart';
import 'package:solo_explore/main.dart';

void main() {
  testWidgets('SoloExplore app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloExploreApp());
    expect(find.byType(SoloExploreApp), findsOneWidget);
  });
}
