import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart'; // 👈 for 3D character
import 'screening_provider.dart';
import 'package:o3d/o3d.dart';
import '../../analytics/data/analytics_service.dart';

class ScreeningResultScreen extends ConsumerWidget {
  const ScreeningResultScreen({super.key});

  // 🔹 Map severity based on test type + score
  String _mapSeverity(int score, String testType) {
    if (testType == "PHQ-9") {
      if (score <= 4) return "minimal";
      if (score <= 9) return "mild";
      if (score <= 14) return "moderate";
      if (score <= 19) return "moderately severe";
      return "severe";
    } else if (testType == "GAD-7") {
      if (score <= 4) return "minimal";
      if (score <= 9) return "mild";
      if (score <= 14) return "moderate";
      return "severe";
    }
    return "unknown";
  }

  // 🔹 Supportive messages for the quote bubble
  String _quoteMessage(String severity) {
    switch (severity) {
      case "minimal":
        return "You're doing well 🌱 — keep taking care of yourself.";
      case "mild":
        return "It’s okay to feel stressed sometimes. Small steps matter 💪.";
      case "moderate":
        return "You're not alone. Talking to a counselor could really help 🤝.";
      case "moderately severe":
        return "It looks like you're struggling 💔. Reaching out for help can make a big difference.";
      case "severe":
        return "You’re going through a tough time 💔. Please reach out to a mental health professional — you deserve support.";
      default:
        return "Take care of yourself 💜. You're not alone.";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final testType = ref.watch(selectedTestProvider) ?? "PHQ-9"; // default
    final answersProviderForThisTest = answersProviderForTest(testType);
    final score = ref.watch(
      scoreProviderForAnswers(answersProviderForThisTest),
    );

    final maxScore = testType == "PHQ-9" ? 27 : 21;
    final severity = _mapSeverity(score, testType);
    final message = _quoteMessage(severity);

    // 🔹 Log analytics event
    analyticsService.logEvent(
      "screening_completed",
      params: {
        "type": testType.replaceAll("-", ""), // PHQ9 / GAD7
        "score": score,
        "severity": severity,
        "timestamp": DateTime.now().toIso8601String(),
      },
    );

    O3DController o3dController = O3DController();

    return Scaffold(
      appBar: AppBar(title: const Text("Your Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 3D Character
            // Expanded(
            //   child: ModelViewer(
            //     src: 'assets/character.glb', // 👈 put your 3D model here
            //     alt: "3D Character",
            //     autoRotate: true,
            //     cameraControls: false,
            //   ),
            // ),
            SizedBox(
              height: 300, // or Expanded if you prefer full space
              child: O3D.asset(
                src: 'assets/character.glb',
                controller: o3dController,
                ar: false,
                autoRotate: true,
                autoPlay: true,
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Quote Bubble
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Score Display
            Text(
              "$testType Score: $score / $maxScore",
              style: theme.textTheme.headlineSmall,
            ),
            Text(
              "Severity: ${severity.toUpperCase()}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: severity == "minimal"
                    ? Colors.green
                    : severity == "mild"
                    ? Colors.yellow[800]
                    : severity == "moderate"
                    ? Colors.orange
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Finish button
            ElevatedButton(
              onPressed: () async {
                await ref.read(saveResultProvider(testType).future);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Result saved securely.")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
              ),
              child: const Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
