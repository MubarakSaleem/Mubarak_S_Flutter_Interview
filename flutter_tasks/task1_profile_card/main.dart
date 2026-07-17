import 'package:flutter/material.dart';
import 'profile_card.dart';

/// Demo app showing ProfileCard on:
///  - a simulated phone width (360dp) via a constrained SizedBox
///  - a simulated tablet width (800dp) via a constrained SizedBox
///  - both light and dark theme, toggled by a switch.
///
/// In a real device this same widget just fills whatever width its parent
/// gives it — the constrained boxes here exist purely so both breakpoints
/// are visible in one screen for the reviewer.
void main() {
  runApp(const ProfileCardDemoApp());
}

class ProfileCardDemoApp extends StatefulWidget {
  const ProfileCardDemoApp({super.key});

  @override
  State<ProfileCardDemoApp> createState() => _ProfileCardDemoAppState();
}

class _ProfileCardDemoAppState extends State<ProfileCardDemoApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfileCard Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ProfileCard Demo'),
          actions: [
            Row(
              children: [
                const Text('Dark'),
                Switch(
                  value: _isDark,
                  onChanged: (v) => setState(() => _isDark = v),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Phone width (360dp)'),
              const SizedBox(height: 8),
              SizedBox(
                width: 360,
                child: ProfileCard(
                  name: 'Rishitha Chinnaraju',
                  designation: 'Flutter Developer',
                  avatarUrl: 'https://i.pravatar.cc/150?img=47',
                  stats: const [
                    ProfileStat(label: 'Posts', value: '128'),
                    ProfileStat(label: 'Followers', value: '3.2K'),
                    ProfileStat(label: 'Following', value: '210'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Tablet width (800dp)'),
              const SizedBox(height: 8),
              SizedBox(
                width: 800,
                child: ProfileCard(
                  name: 'Rishitha Chinnaraju',
                  designation: 'Senior Flutter Developer',
                  avatarUrl: 'https://broken-url-example.invalid/avatar.png',
                  stats: const [
                    ProfileStat(label: 'Posts', value: '128'),
                    ProfileStat(label: 'Followers', value: '3.2K'),
                    ProfileStat(label: 'Following', value: '210'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
