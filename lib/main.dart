import 'package:digital_mental_health_app/feature/booking/presentation/booking_screen.dart';
import 'package:digital_mental_health_app/feature/resources/presenetation/resources_screen.dart';
import 'package:digital_mental_health_app/feature/screeening/presentation/screening_screen.dart';
import 'package:digital_mental_health_app/feature/splash/presentation/splash_screen.dart';
import 'package:digital_mental_health_app/feature/theme/presentation/theme_provider.dart';
import 'package:digital_mental_health_app/feature/profile/presentation/profile_screen.dart';
import 'package:digital_mental_health_app/feature/chatbot/chat_bot_screen.dart';
import 'package:digital_mental_health_app/feature/forum/presentation/forum_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      // Riverpod scope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeModeProvider);

    // Map enum to Flutter ThemeMode
    ThemeMode themeMode;
    switch (appTheme) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Digital Mental Health',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),

      routes: {
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        ChatbotScreen.routeName: (context) {
          final initialMood =
              ModalRoute.of(context)!.settings.arguments as String;
          return ChatbotScreen(initialMood: initialMood);
        },
        ResourcesScreen.routeName: (context) => const ResourcesScreen(),
        ForumScreen.routeName: (context) => const ForumScreen(),
        BookingScreen.routeName: (context) => const BookingScreen(),
        ScreeningScreen.routeName: (context) => const ScreeningScreen(),
      },
    );
  }
}
