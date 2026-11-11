import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'has_completed_onboarding_v2': true});
  });

  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LudoGlobalApp());
    expect(find.text('LUDO'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Advance clock past splash screen transition
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify it transitioned to MainSocialShell (HomeScreen)
    expect(find.text('PLAY TOGETHER'), findsOneWidget);
    expect(find.text('FRIENDS ONLINE'), findsOneWidget);
  });
}
