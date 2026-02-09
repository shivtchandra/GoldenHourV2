import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/providers/user_provider.dart';
import '../../user/providers/user_profile_provider.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier(this._prefs, this._ref) : super(AuthState(
    isAuthenticated: FirebaseAuth.instance.currentUser != null,
  ));

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _prefs.setBool('is_authenticated', true);

      // Refresh user profile from Firestore to get the correct user data
      await _ref.read(userProfileProvider.notifier).refreshProfile();

      // Sync any onboarding data collected before login
      _syncOnboardingDataToFirebase();

      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Authentication failed.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  /// Sync onboarding preferences to Firebase after authentication
  void _syncOnboardingDataToFirebase() {
    try {
      final onboardingData = _ref.read(onboardingProvider);
      if (onboardingData.toolkitCameraIds.isNotEmpty ||
          onboardingData.whyFilm != null ||
          onboardingData.favoriteEra != null) {
        _ref.read(onboardingProvider.notifier).saveToFirebase();
      }
    } catch (e) {
      // Silently fail - onboarding data is optional
      print('Failed to sync onboarding data: $e');
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);

      await _prefs.setBool('is_authenticated', true);

      // Refresh profile - this will create a new Firestore document for the user
      await _ref.read(userProfileProvider.notifier).refreshProfile();

      // Update name if needed (in case displayName wasn't picked up)
      if (name.isNotEmpty) {
        await _ref.read(userProfileProvider.notifier).setName(name);
      }

      // Sync any onboarding data collected before signup
      _syncOnboardingDataToFirebase();

      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Sign up failed.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _prefs.setBool('is_authenticated', false);
    _ref.read(userProfileProvider.notifier).signOut();
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthNotifier(prefs, ref);
});
