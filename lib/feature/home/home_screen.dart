import 'package:digital_mental_health_app/feature/profile/presentation/profile_screen.dart';
import 'package:digital_mental_health_app/feature/resources/presenetation/resources_screen.dart';
import 'package:digital_mental_health_app/feature/screeening/presentation/screening_screen.dart';
import 'package:digital_mental_health_app/feature/activities/presentation/activities_screen.dart';
import 'package:digital_mental_health_app/feature/analytics/presentation/analytics_screen.dart';
import 'package:digital_mental_health_app/feature/booking/presentation/booking_screen.dart';
import 'package:digital_mental_health_app/feature/diary/presentation/diary_screen.dart';
import 'package:digital_mental_health_app/feature/forum/presentation/forum_screen.dart';
import 'package:digital_mental_health_app/feature/analytics/data/analytics_service.dart';
import 'package:digital_mental_health_app/feature/auth/presentation/auth_provider.dart';
import 'package:digital_mental_health_app/feature/home/data/mood_service.dart';
import 'package:digital_mental_health_app/feature/chatbot/chat_bot_screen.dart';
import 'package:digital_mental_health_app/core/notifications/notification_modal.dart';
import 'package:digital_mental_health_app/core/notifications/notification_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showMoodCheck = false;

  @override
  void initState() {
    super.initState();
    _checkMoodVisibility();

    // Log screen view for analytics
    analyticsService.logScreenView("home_screen");
  }

  Future<void> _saveMoodCheck(BuildContext context, String mood) async {
    // Immediately hide the modal
    setState(() {
      _showMoodCheck = false;
    });

    // Save timestamp in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      "last_mood_check",
      DateTime.now().millisecondsSinceEpoch,
    );

    // Map mood to number
    int moodValue = switch (mood) {
      "happy" => 1,
      "neutral" => 0,
      "sad" => -1,
      _ => 0,
    };

    final student = ref.read(authStateProvider);
    if (student == null) throw Exception("Student not found");

    // Fire-and-forget async saves (don't block UI)
    Future.microtask(() async {
      await MoodCheckService().saveMood(
        student.prn,
        student.college,
        moodValue,
      );
      await analyticsService.logEvent(
        "mood_selected",
        params: {"mood": moodValue, "timestamp": FieldValue.serverTimestamp()},
      );
    });

    // Navigate ONLY if mood is sad
    if (mood == "sad") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatbotScreen(initialMood: mood)),
      );
    }
  }

  Future<void> _checkMoodVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckIn = prefs.getInt("last_mood_check") ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final oneHour = 60 * 60 * 1000;

    setState(() {
      _showMoodCheck = (now - lastCheckIn) >= oneHour;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);
    // final auth = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Fetch notifications from Firestore or local cache
              final notifications =
                  <NotificationModel>[]; // Replace with real data
              showNotificationModal(context, notifications);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
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
                  _buildFeatureCard(context, Icons.chat, "Lumi", () {
                    // Navigate to Chatbot screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ChatbotScreen(initialMood: "none"),
                      ),
                    );
                  }),
                  _buildFeatureCard(context, Icons.book, "Resources", () {
                    // Navigate to Resources screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResourcesScreen(),
                      ),
                    );
                  }),
                  _buildFeatureCard(context, Icons.forum, "Peer Forum", () {
                    // Navigate to Forum screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForumScreen(),
                      ),
                    );
                  }),
                  _buildFeatureCard(
                    context,
                    Icons.calendar_today,
                    "Counsellor",
                    () {
                      // Navigate to Booking screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(context, Icons.assignment, "Screening", () {
                    // Navigate to Screening screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreeningScreen(),
                      ),
                    );
                  }),

                  _buildFeatureCard(context, Icons.analytics, "Analytics", () {
                    // Navigate to Profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  }),

                  _buildFeatureCard(
                    context,
                    Icons.book_outlined,
                    "Daily Diary",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiaryScreen(),
                        ),
                      );
                    },
                  ),

                  _buildFeatureCard(
                    context,
                    Icons.games,
                    "Mini Activities",
                    () {
                      // Navigate to Profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActivitiesScreen(),
                        ),
                      );
                    },
                  ),

                  // Profile
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

              SizedBox(
                height: 450,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    // Mood Check
                    if (_showMoodCheck) _buildMoodCheckIn(theme),

                    const SizedBox(height: 16),

                    // 4. Featured Resource
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
                      child: Text(
                        'From resources',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    _buildResourceCard(
                      theme,
                      "🎧 Today’s Pick: Guided Meditation (5 min)",
                    ),

                    const SizedBox(height: 16),

                    // 5. Community Highlight
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
                      child: Text(
                        'From community',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    _buildCommunityCard(
                      theme,
                      "Student A: How do you deal with exam stress?",
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
                      child: Text(
                        'Tip of the Day',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    _buildTipCard(
                      theme,
                      "Take a short walk to refresh your mind.",
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                      child: Text(
                        'Sessions',
                        style: theme.textTheme.titleMedium,
                      ),
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
                    // 6. Encouragement Footer
                    _buildFooter(theme, "You are stronger than you think"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCheckIn(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How are you feeling today?",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Text("😄", style: TextStyle(fontSize: 28)),
                    onPressed: () => _saveMoodCheck(context, "happy"),
                  ),
                  IconButton(
                    icon: const Text("😐", style: TextStyle(fontSize: 28)),
                    onPressed: () => _saveMoodCheck(context, "neutral"),
                  ),
                  IconButton(
                    icon: const Text("☹️", style: TextStyle(fontSize: 28)),
                    onPressed: () => _saveMoodCheck(context, "sad"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(
            Icons.play_circle_fill,
            color: theme.colorScheme.primary,
            size: 40,
          ),
          title: Text(title, style: theme.textTheme.bodyMedium),
          trailing: ElevatedButton(
            onPressed: () {},
            child: const Text("Play Now"),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(ThemeData theme, String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(Icons.forum, color: theme.colorScheme.primary),
          title: Text(question, style: theme.textTheme.bodyMedium),
          trailing: ElevatedButton(onPressed: () {}, child: const Text("Join")),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, String message) {
    return Center(
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme, String tip) {
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
              Icon(Icons.lightbulb, color: theme.colorScheme.primary, size: 28),
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
          leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
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
