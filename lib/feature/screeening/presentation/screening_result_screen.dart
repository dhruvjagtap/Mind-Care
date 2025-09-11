import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screening_provider.dart';
import '../../analytics/analytics_service.dart';

class ScreeningResultScreen extends ConsumerWidget {
  const ScreeningResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final testType = ref.watch(selectedTestProvider) ?? "Unknown";

    String _mapSeverity(int score) {
      if (score <= 4) return "minimal";
      if (score <= 9) return "mild";
      if (score <= 14) return "moderate";
      if (score <= 19) return "moderately severe";
      return "severe";
    }

    analyticsService.logEvent(
      "screening_completed",
      params: {
        "type": "PHQ9", // or "GAD7"
        "score": score, // integer
        "severity": _mapSeverity(score), // e.g. "mild", "moderate", "severe"
        "timestamp": DateTime.now().toIso8601String(),
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Your $testType Score",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              "Score: $score / 27",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await ref.read(
                  saveResultProvider(testType).future,
                ); // save to Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Result saved securely.")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
