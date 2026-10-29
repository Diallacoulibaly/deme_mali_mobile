
import 'package:flutter_test/flutter_test.dart';
import 'package:deme_mali_mobile/main.dart';

void main() {
  testWidgets('Dèmè Mali démarre correctement', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const DemeMaliApp());

    expect(find.byType(DemeMaliApp), findsOneWidget);
  });
}
