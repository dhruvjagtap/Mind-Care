import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mini Activities")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivityCard(
            theme,
            "Breathing Exercise",
            "Relax with guided breathing",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BreathingExerciseScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            theme,
            "📝 Quick Journal",
            "Write down your thoughts",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JournalingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            theme,
            "🎮 Memory Game",
            "Boost focus with a quick game",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    ThemeData theme,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class BreathingExerciseScreen extends StatelessWidget {
  const BreathingExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Breathing Exercise")),
    body: const Center(child: Text("Breathing guide goes here")),
  );
}

class JournalingScreen extends StatelessWidget {
  const JournalingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Journaling")),
    body: const Center(child: Text("Simple journaling UI")),
  );
}

class MemoryGameScreen extends StatelessWidget {
  const MemoryGameScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Memory Game")),
    body: const Center(child: Text("Game UI here")),
  );
}
