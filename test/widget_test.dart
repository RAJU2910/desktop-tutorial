import 'package:flutter_test/flutter_test.dart';
import 'package:instalite_flutter/main.dart';

void main() {
  testWidgets('login screen renders', (tester) async {
    await tester.pumpWidget(const InstaLiteApp());
    expect(find.text('InstaLite'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });
}
