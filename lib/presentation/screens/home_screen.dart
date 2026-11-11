import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import 'main_social_shell.dart';

/// Legacy HomeScreen wrapper that immediately presents the MainSocialShell
class HomeScreen extends StatelessWidget {
  final UserProfile userProfile;

  const HomeScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return MainSocialShell(userProfile: userProfile);
  }
}
