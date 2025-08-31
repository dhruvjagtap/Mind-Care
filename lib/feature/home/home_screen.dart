import 'package:digital_mental_health_app/feature/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../auth/presentation/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Welcome to Mind Care',
                style: theme.textTheme.headlineSmall,
              ),
            ),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFeatureCard(context, Icons.chat, "AI Chatbot", () {
                  // Navigate to Chatbot screen
                }),
                _buildFeatureCard(context, Icons.book, "Resources", () {
                  // Navigate to Resources screen
                }),
                _buildFeatureCard(context, Icons.forum, "Peer Forum", () {
                  // Navigate to Forum screen
                }),
                _buildFeatureCard(
                  context,
                  Icons.calendar_today,
                  "Counsellor",
                  () {
                    // Navigate to Booking screen
                  },
                ),
                _buildFeatureCard(context, Icons.assignment, "Screening", () {
                  // Navigate to Screening screen
                }),
                _buildFeatureCard(context, Icons.person, "Profile", () {
                  // Navigate to Profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Tip of the Day', style: theme.textTheme.titleMedium),
            ),
            _buildTipCard(context, "Take a short walk to refresh your mind."),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text('Sessions', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            _buildSessionCard(
              context,
              title: "No upcoming session",
              subtitle: "Book a session with a counsellor",
              buttonText: "Book Now",
              onPressed: () {
                // Navigate to Booking screen
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, String tip) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: theme.colorScheme.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.teal, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(tip, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Card(
        color: theme.colorScheme.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.teal),
          title: Text(title, style: theme.textTheme.bodyMedium),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
          trailing: ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ),
      ),
    );
  }
}
