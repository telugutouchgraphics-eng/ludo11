import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/core/constants/app_colors.dart';
import 'package:ludo_global/models/user_profile.dart';
import 'package:ludo_global/presentation/screens/direct_chat_screen.dart';
import 'package:ludo_global/presentation/widgets/social/story_viewer_dialog.dart';

void main() {
  testWidgets('DirectChatScreen renders correctly with message bubbles and composer', (WidgetTester tester) async {
    final profile = UserProfile(
      name: 'Alex',
      coins: 2000,
      level: 1,
      xp: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DirectChatScreen(
          userProfile: profile,
          friendName: 'Priya',
          friendEmoji: '💖',
          friendColor: AppColors.roseGoldPrimary,
        ),
      ),
    );

    // Initial pump
    await tester.pump(const Duration(milliseconds: 300));

    // Verify friend name and elements
    expect(find.text('Priya'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // Send a message
    await tester.enterText(find.byType(TextField), 'Hello Priya! Ready for Ludo?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hello Priya! Ready for Ludo?'), findsOneWidget);
  });

  testWidgets('StoryViewerDialog renders with story caption and progress bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StoryViewerDialog(
            userName: 'Rahul K.',
            userEmoji: '⚡',
            userRingColor: AppColors.greenPrimary,
            storyCaption: 'Clutch win in 4P match! 🏆',
          ),
        ),
      ),
    );

    // Advance 500ms
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Rahul K.'), findsOneWidget);
    expect(find.text('Clutch win in 4P match! 🏆'), findsOneWidget);
    expect(find.text('Send a reply to Rahul K....'), findsOneWidget);
  });
}
