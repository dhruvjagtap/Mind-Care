import 'package:flutter/material.dart';
import 'add_entry_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Diary")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text("Today’s Entry"),
              subtitle: const Text("Tap to write your thoughts"),
              trailing: const Icon(Icons.add),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEntryScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text("Recent Entries", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: const Text("16 Sep 2025"),
            subtitle: const Text("Felt good after meditation"),
            leading: const Icon(Icons.book),
            onTap: () {},
          ),
          ListTile(
            title: const Text("15 Sep 2025"),
            subtitle: const Text("A little stressed with work"),
            leading: const Icon(Icons.book),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
