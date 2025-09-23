// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../analytics/data/analytics_service.dart';
// import 'screening_provider.dart';
// import 'phq9_test_screen.dart';
// import 'gad7_test_screen.dart';

// class ScreeningScreen extends ConsumerStatefulWidget {
//   static const routeName = '/screening';
//   const ScreeningScreen({super.key});

//   @override
//   ConsumerState<ScreeningScreen> createState() => _ScreeningScreenState();
// }

// class _ScreeningScreenState extends ConsumerState<ScreeningScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: Text('Screening')),
//       body: Padding(
//         padding: EdgeInsets.all(8),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Card(
//                 elevation: 1.5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Container(
//                   width: 300,
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Instructions', style: theme.textTheme.titleMedium),
//                       const SizedBox(height: 8),

//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "PHQ-9 (Patient Health Questionnaire-9)\n"
//                             "This is a widely used questionnaire developed by medical researchers. "
//                             "It helps measure the severity of depression symptoms. "
//                             "It is not a diagnosis, but it can guide you towards seeking professional support.\n\n"
//                             "GAD-7 (Generalized Anxiety Disorder-7)\n"
//                             "This short questionnaire is designed to assess symptoms of anxiety. "
//                             "It helps identify how often you may have felt anxious in the last 2 weeks.\n\n"
//                             "Instructions:",

//                             style: theme.textTheme.bodyMedium,
//                           ),

//                           const SizedBox(height: 8),

//                           _buildBulletPoint(
//                             "Answer honestly about how you felt in the last 2 weeks.",
//                             theme,
//                           ),
//                           _buildBulletPoint(
//                             "Options: Not at all (0), Several days (1), More than half the days (2), Nearly every day (3).",
//                             theme,
//                           ),
//                           _buildBulletPoint(
//                             "Your responses will remain confidential.",
//                             theme,
//                           ),
//                           _buildBulletPoint(
//                             "If you ever feel like harming yourself, please seek immediate help.",
//                             theme,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Test Selection Card
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(6),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Choose a Test', style: theme.textTheme.titleMedium),
//                       const SizedBox(height: 8),

//                       ElevatedButton(
//                         onPressed: () {
//                           ref.read(selectedTestProvider.notifier).state =
//                               "PHQ-9";

//                           // Analytics screen
//                           analyticsService.logEvent(
//                             "screening_started",
//                             params: {
//                               "type": "PHQ9",
//                               "timestamp": DateTime.now().toIso8601String(),
//                             },
//                           );

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const Phq9TestScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text("PHQ-9 (Depression)"),
//                       ),
//                       const SizedBox(height: 12),

//                       ElevatedButton(
//                         onPressed: () {
//                           ref.read(selectedTestProvider.notifier).state =
//                               "GAD-7";

//                           analyticsService.logEvent(
//                             "screening_started",
//                             params: {
//                               "type": "GAD7",
//                               "timestamp": DateTime.now().toIso8601String(),
//                             },
//                           );

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const Gad7TestScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text("GAD-7 (Anxiety)"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBulletPoint(String text, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.circle, size: 8, color: theme.colorScheme.onBackground),
//           const SizedBox(width: 8),
//           Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/data/analytics_service.dart';
import 'screening_provider.dart';
import 'phq9_test_screen.dart';
import 'gad7_test_screen.dart';

class ScreeningScreen extends ConsumerStatefulWidget {
  static const routeName = '/screening';
  const ScreeningScreen({super.key});

  @override
  ConsumerState<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends ConsumerState<ScreeningScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instructionColor = Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(title: const Text('Screening')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Screening Instructions",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: instructionColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Please read the following carefully before starting the tests. Answer honestly to get accurate feedback. Your responses are confidential and not a diagnosis.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: instructionColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextBullet(
                          "PHQ-9 (Patient Health Questionnaire-9): Measures severity of depression symptoms.",
                          theme,
                          instructionColor,
                        ),
                        _buildTextBullet(
                          "GAD-7 (Generalized Anxiety Disorder-7): Assesses symptoms of anxiety over the past 2 weeks.",
                          theme,
                          instructionColor,
                        ),
                        _buildTextBullet(
                          "Answer honestly about how you felt in the last 2 weeks.",
                          theme,
                          instructionColor,
                        ),
                        _buildTextBullet(
                          "Options: Not at all (0), Several days (1), More than half the days (2), Nearly every day (3).",
                          theme,
                          instructionColor,
                        ),
                        _buildTextBullet(
                          "If you ever feel like harming yourself, please seek immediate help.",
                          theme,
                          instructionColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Test Selection Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a Test',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTestButton(
                          label: "PHQ-9 (Depression)",
                          icon: Icons.favorite,
                          theme: theme,
                          onPressed: () {
                            ref.read(selectedTestProvider.notifier).state =
                                "PHQ-9";

                            analyticsService.logEvent(
                              "screening_started",
                              params: {
                                "type": "PHQ9",
                                "timestamp": DateTime.now().toIso8601String(),
                              },
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Phq9TestScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTestButton(
                          label: "GAD-7 (Anxiety)",
                          icon: Icons.psychology,
                          theme: theme,
                          onPressed: () {
                            ref.read(selectedTestProvider.notifier).state =
                                "GAD-7";

                            analyticsService.logEvent(
                              "screening_started",
                              params: {
                                "type": "GAD7",
                                "timestamp": DateTime.now().toIso8601String(),
                              },
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Gad7TestScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextBullet(String text, ThemeData theme, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: color,
              fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 1.5,
              height: 1.55, // makes bullet align nicely with text
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required IconData icon,
    required ThemeData theme,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: theme.colorScheme.primary,
          elevation: 4,
        ),
      ),
    );
  }
}
