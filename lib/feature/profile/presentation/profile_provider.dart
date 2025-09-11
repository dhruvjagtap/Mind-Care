import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_service.dart';

/// Provider for ProfileService (Firebase interactions)
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Async provider to fetch the user profile from Firestore
final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(profileServiceProvider);
  return service.getProfile();
});

/// StateNotifier for updating and holding profile data
class ProfileNotifier extends StateNotifier<Map<String, dynamic>> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super({});

  /// Update local state
  void updateField(String key, dynamic value) {
    state = {...state, key: value};
  }

  /// Save to Firestore
  Future<void> saveProfile() async {
    await _service.updateProfile(state);
  }

  /// Load from Firestore into state
  Future<void> loadProfile() async {
    final data = await _service.getProfile();
    if (data != null) {
      state = data;
    }
  }
}

/// StateNotifierProvider for Profile
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, Map<String, dynamic>>((ref) {
      final service = ref.watch(profileServiceProvider);
      final notifier = ProfileNotifier(service);

      // Auto fetch the profile when provider is created
      notifier.loadProfile();

      return notifier;
    });
