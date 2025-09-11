// lib/feature/analytics/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}

final analyticsService = AnalyticsService();


// what is firebase analytics  how can i implement in this case

// i think you lost again come back to right place again 

// what we are doing i have completed my appp about 75% 

// MindCare: Digital Mental Health Support for Students

// Project Overview
// Mental health challenges among higher education students—such as anxiety, depression, academic stress, burnout, sleep disorders, and social isolation—are increasingly prevalent. Despite the availability of college counselling centers, many students avoid seeking help due to fear of judgment, stigma, or lack of awareness. Existing mental health apps are often generic, Western-oriented, or paid, lacking regional relevance and integration with institutional support systems.
// Objective:
//  To create a digital, stigma-free, and regionally adapted mental health support system for students in higher education, which includes both a student-facing mobile app and an admin/counsellor web dashboard for institutions.

// Key Features
// 1. Student Mobile App (Flutter – Android/iOS)
//         A safe, user-friendly, and anonymous platform for students to access mental health support.
// Core Modules:

// 1. Anonymous Login & Profile
// Students can login without providing personal details.
// Minimal optional profile information: year of study, department, age group.
// Ensures privacy and confidentiality.

// 2. AI-Guided Chatbot (First-Aid Support)
// Interactive chatbot providing coping strategies for stress, anxiety, and burnout.
// Rule-based chatbot initially; later integration with Dialogflow or OpenAI API for smarter, context-aware support.
// Suggests resource links or refers students to counsellors if issues require professional help.

// 3. Resource Hub (Psychoeducational Content)
// Videos, audios, and PDF guides on mental wellness, relaxation, meditation, and time management.
// Regional language support for inclusivity.
// Offline download option for rural/semi-urban students.

// 4. Peer Support Forum
// Anonymous peer-to-peer discussion platform.
// Students can share experiences and provide mutual support.
// Moderated to prevent misuse or inappropriate content.

// 5. Confidential Counsellor Booking
// Students can book appointments with on-campus counsellors.
// Select date, time slot, and mode (chat/video/voice – demo can focus on chat).
// Data stored securely with anonymized identifiers.

// 6. Optional Screening Tools
// Standardized questionnaires (PHQ-9, GAD-7) to assess stress, depression, or anxiety levels.
// Results visible only to the student unless explicitly shared with counsellors.

// this is my app about 

// and what i have implemented till now is 

// .
// ├── auth
// │   ├── data
// │   │   └── auth_service.dart
// │   └── presentation
// │       ├── auth_checker.dart
// │       ├── auth_provider.dart
// │       └── login_screen.dart
// ├── booking
// │   ├── data
// │   │   ├── booking_model.dart
// │   │   ├── booking_repository.dart
// │   │   └── slots_model.dart
// │   └── presentation
// │       ├── booking_form.dart
// │       ├── booking_provider.dart
// │       ├── booking_screen.dart
// │       └── my_bookings_screen.dart
// ├── chatbot
// │   └── chat_bot_screen.dart
// ├── forum
// │   └── presentation
// │       ├── forum_provider.dart
// │       └── forum_screen.dart
// ├── home
// │   └── home_screen.dart
// ├── profile
// │   ├── data
// │   │   └── profile_service.dart
// │   └── presentation
// │       ├── oboarding_modal.dart
// │       ├── profile_provider.dart
// │       └── profile_screen.dart
// ├── resources
// │   ├── data
// │   │   ├── resource_model.dart
// │   │   └── resource_service.dart
// │   └── presenetation
// │       ├── resource_provider.dart
// │       └── resources_screen.dart
// ├── screeening
// │   ├── data
// │   │   ├── screening_model.dart
// │   │   ├── screening_repository.dart
// │   │   └── screening_service.dart
// │   └── presentation
// │       ├── gad7_test_screen.dart
// │       ├── phq9_test_screen.dart
// │       ├── screening_provider.dart
// │       ├── screening_result_screen.dart
// │       └── screening_screen.dart
// ├── splash
// │   └── presentation
// │       ├── mind_care_loader.dart
// │       └── splash_screen.dart
// └── theme
//     └── presentation
//         └── theme_provider.dart

// 🎯 Why Firebase Analytics in MindCare?

// Analytics isn’t about tracking who the student is (we’re keeping anonymity).
// It’s about tracking how the app is being used so:

// Student Perspective (Personalized Experience)

// Mood check-ins: see if their mood is improving or declining.

// Screening completion: nudge if they haven’t done PHQ-9/GAD-7 in a while.

// Resource usage: recommend more content based on what they use.

// Chatbot use: detect if someone keeps opening chatbot after sad moods → send helpful daily tips.

// Admin / Counsellor Perspective (Aggregated Insights)

// Which features are students using the most? (Chatbot vs Forum vs Resources).

// Which screening tools are being completed more often?

// Are students actually booking counsellors or just browsing resources?

// Anonymous trends across the student population → helps improve institutional support.

// 📌 Events We Should Track (in your current structure)

// Based on your folder breakdown, here’s how each module benefits:

// Home (mood check-in)
// → Track: which emoji is pressed (😄 / 😐 / ☹️).
// → Why: helps us understand stress patterns.

// Screening (PHQ-9, GAD-7)
// → Track: screening started, screening completed, result category (mild/moderate/severe).
// → Why: nudges user to take follow-up or recommend resources.

// Chatbot
// → Track: chatbot opened, number of messages exchanged.
// → Why: if someone is coming often, they may need escalation or counselling booking.

// Resources
// → Track: resource type opened (video/audio/PDF), duration spent.
// → Why: helps recommend “similar” resources later.

// Booking
// → Track: booking requested, slot selected, booking completed.
// → Why: gives institution insight into counselling demand.

// Forum
// → Track: post created, reply created, flagged post.
// → Why: monitor engagement + health of peer support.