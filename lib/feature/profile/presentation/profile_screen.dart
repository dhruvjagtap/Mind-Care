import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/presentation/theme_provider.dart'; // where themeModeProvider lives
import 'profile_provider.dart'; // adjust the path to where your profile provider lives

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// --- Profile Information ---
          const Text(
            "Profile Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text("Name: ${profile["name"] ?? "Not set"}"),
          Text("PRN: ${profile["prn"] ?? "Not set"}"),
          Text("Hobbies: ${(profile["hobbies"] ?? []).join(", ")}"),
          if (profile["otherHobby"] != null &&
              profile["otherHobby"].toString().isNotEmpty)
            Text("Other Hobby: ${profile["otherHobby"]}"),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              ref
                  .read(profileNotifierProvider.notifier)
                  .updateField("name", "New Name");
              await ref.read(profileNotifierProvider.notifier).saveProfile();
            },
            child: const Text("Update Name"),
          ),

          const Divider(height: 40),

          /// --- Theme Section ---
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          RadioListTile<AppThemeMode>(
            title: const Text("System Default"),
            value: AppThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) =>
                ref.read(themeModeProvider.notifier).state = value!,
          ),
          RadioListTile<AppThemeMode>(
            title: const Text("Light Mode"),
            value: AppThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) =>
                ref.read(themeModeProvider.notifier).state = value!,
          ),
          RadioListTile<AppThemeMode>(
            title: const Text("Dark Mode"),
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) =>
                ref.read(themeModeProvider.notifier).state = value!,
          ),
        ],
      ),
    );
  }
}
