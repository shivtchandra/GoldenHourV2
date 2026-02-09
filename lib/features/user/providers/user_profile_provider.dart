import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_profile.dart';
import '../data/services/user_service.dart';

/// Provider for UserService singleton
final userServiceProvider = Provider<UserService>((ref) => UserService());

/// Provider for current user's profile (async)
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getCurrentUserProfile();
});

/// Provider for current user's profile stream (real-time)
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final service = ref.watch(userServiceProvider);
  return service.watchCurrentUserProfile();
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return FirebaseAuth.instance.currentUser != null;
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// Provider for film usage stats
final filmUsageStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getFilmUsageStats();
});

/// Provider for favorite film
final favoriteFilmProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getFavoriteFilm();
});

/// Provider for pro status
final isProUserProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.isProUser();
});

/// State notifier for onboarding data collection
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  final UserService _userService;

  OnboardingNotifier(this._userService) : super(OnboardingData());

  void setWhyFilm(String value) {
    state = OnboardingData(
      whyFilm: value,
      favoriteEra: state.favoriteEra,
      subjects: state.subjects,
      workflow: state.workflow,
      aspectRatio: state.aspectRatio,
      toolkitCameraIds: state.toolkitCameraIds,
    );
  }

  void setFavoriteEra(String value) {
    state = OnboardingData(
      whyFilm: state.whyFilm,
      favoriteEra: value,
      subjects: state.subjects,
      workflow: state.workflow,
      aspectRatio: state.aspectRatio,
      toolkitCameraIds: state.toolkitCameraIds,
    );
  }

  void toggleSubject(String subject) {
    final subjects = List<String>.from(state.subjects);
    if (subjects.contains(subject)) {
      subjects.remove(subject);
    } else {
      subjects.add(subject);
    }
    state = OnboardingData(
      whyFilm: state.whyFilm,
      favoriteEra: state.favoriteEra,
      subjects: subjects,
      workflow: state.workflow,
      aspectRatio: state.aspectRatio,
      toolkitCameraIds: state.toolkitCameraIds,
    );
  }

  void setWorkflow(String value) {
    state = OnboardingData(
      whyFilm: state.whyFilm,
      favoriteEra: state.favoriteEra,
      subjects: state.subjects,
      workflow: value,
      aspectRatio: state.aspectRatio,
      toolkitCameraIds: state.toolkitCameraIds,
    );
  }

  void setAspectRatio(String value) {
    state = OnboardingData(
      whyFilm: state.whyFilm,
      favoriteEra: state.favoriteEra,
      subjects: state.subjects,
      workflow: state.workflow,
      aspectRatio: value,
      toolkitCameraIds: state.toolkitCameraIds,
    );
  }

  void setToolkitCameras(List<String> ids) {
    state = OnboardingData(
      whyFilm: state.whyFilm,
      favoriteEra: state.favoriteEra,
      subjects: state.subjects,
      workflow: state.workflow,
      aspectRatio: state.aspectRatio,
      toolkitCameraIds: ids,
    );
  }

  /// Save onboarding data to Firebase
  Future<void> saveToFirebase() async {
    try {
      await _userService.saveOnboardingData(state);
    } catch (e) {
      // Log error but don't crash - local storage is fallback
      print('Failed to save onboarding to Firebase: $e');
    }
  }

  /// Reset onboarding data
  void reset() {
    state = OnboardingData();
  }
}

/// Provider for onboarding state management
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  final userService = ref.watch(userServiceProvider);
  return OnboardingNotifier(userService);
});
