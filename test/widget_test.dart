import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_multi_screen_app/main.dart';

void main() {
  testWidgets('shows login screen on app start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
