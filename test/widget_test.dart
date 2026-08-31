import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';

void main() {
  testWidgets('Auth gate shows role selection when logged out', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SunSafeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Who is using this phone?'), findsOneWidget);
    expect(find.text('Me — Senior Mode'), findsOneWidget);
    expect(find.text('My Parent — Caregiver Mode'), findsOneWidget);
  });
}
