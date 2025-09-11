import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screening_provider.dart';
import 'screening_result_screen.dart';
import '../../analytics/analytics_service.dart';

class Gad7TestScreen extends ConsumerWidget {
  static const routeName = '/phq9';
  const Gad7TestScreen({super.key});

  final List<String> questions = const [
    "Feeling nervous, anxious or on edge",
    "Not being able to stop or control worrying ",
    "Worrying too much about different things",
    "Trouble relaxing",
    "Being so restless that it is hard to sit still",
    "Becoming easily annoyed or irritable",
    "Feeling afraid as if something awful might happen",
  ];

  final List<String> options = const [
    "0 - Not at all",
    "1 - Several days",
    "2 - More than half the days",
    "3 - Nearly every day",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);

    return WillPopScope(
      onWillPop: () async {
        // 👉 if user answered something but didn’t finish, log abandoned
        if (answers.isNotEmpty && answers.length < questions.length) {
          analyticsService.logEvent(
            "screening_abandoned",
            params: {
              "type": "PHQ9",
              "progress": answers.length, // how many answered
              "timestamp": DateTime.now().toIso8601String(),
            },
          );
        }
        return true; // allow going back
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("GAD-7 Test")),
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
                            ref.read(answersProvider.notifier).state =
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScreeningResultScreen(),
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }
}
