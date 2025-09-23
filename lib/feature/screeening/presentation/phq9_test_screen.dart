import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screening_provider.dart';
import 'screening_result_screen.dart';
import '../../analytics/data/analytics_service.dart';

class Phq9TestScreen extends ConsumerWidget {
  static const routeName = '/phq9';
  const Phq9TestScreen({super.key});

  final List<String> questions = const [
    "Little interest or pleasure in doing things?",
    "Feeling down, depressed, or hopeless?",
    "Trouble falling/staying asleep, or sleeping too much?",
    "Feeling tired or having little energy?",
    "Poor appetite or overeating?",
    "Feeling bad about yourself — or that you are a failure?",
    "Trouble concentrating on things?",
    "Moving/speaking so slowly or being restless?",
    "Thoughts that you would be better off dead or of hurting yourself?",
  ];

  final List<String> options = const [
    "0 - Not at all",
    "1 - Several days",
    "2 - More than half the days",
    "3 - Nearly every day",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final answers = ref.watch(answersProviderForTest("PHQ-9"));

    return WillPopScope(
      onWillPop: () async {
        if (answers.isNotEmpty && answers.length < questions.length) {
          analyticsService.logEvent(
            "screening_abandoned",
            params: {
              "type": "PHQ9",
              "progress": answers.length,
              "timestamp": DateTime.now().toIso8601String(),
            },
          );
        }
        return true; // allow going back
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("PHQ-9 Test")),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[index],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(options.length, (optionIndex) {
                        return RadioListTile<int>(
                          title: Text(options[optionIndex]),
                          value: optionIndex,
                          groupValue: index < answers.length
                              ? answers[index]
                              : null,
                          onChanged: (value) {
                            final newAnswers = [...answers];
                            if (index < newAnswers.length) {
                              newAnswers[index] = value!;
                            } else {
                              newAnswers.add(value!);
                            }
                            ref.read(phq9AnswersProvider.notifier).state =
                                newAnswers;
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: answers.length == questions.length
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScreeningResultScreen(),
                      ),
                    );
                  }
                : null, // disables button if not all answered
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
            ),

            child: Text(
              "Submit (${answers.length}/${questions.length})",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
