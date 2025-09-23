import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mood Trends", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: Text("Mood chart here")),
            ),
            const SizedBox(height: 24),
            Text("App Usage", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: Text("Usage chart here")),
            ),
          ],
        ),
      ),
    );
  }
}
