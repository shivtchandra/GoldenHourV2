import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/photo_storage_service.dart';
import '../../camera/data/repositories/camera_repository.dart';
import '../../presets/data/repositories/preset_repository.dart';

/// Model for User Profile
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String membershipStatus;
  final DateTime joinedDate;
  final bool isPro;

  UserProfile({
    this.id = '',
    required this.name,
    required this.email,
    required this.membershipStatus,
    required this.joinedDate,
    this.isPro = false,
  });

  /// Empty profile for unauthenticated state
  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      name: '',
      email: '',
      membershipStatus: 'FREE MEMBER',
      joinedDate: DateTime.now(),
      isPro: false,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? membershipStatus,
    DateTime? joinedDate,
    bool? isPro,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      joinedDate: joinedDate ?? this.joinedDate,
      isPro: isPro ?? this.isPro,
    );
  }

  factory UserProfile.fromFirestore(String docId, Map<String, dynamic> data) {
    return UserProfile(
      id: docId,
      name: data['name'] ?? data['displayName'] ?? '',
      email: data['email'] ?? '',
      membershipStatus: data['isPro'] == true ? 'ROYAL MEMBER' : 'FREE MEMBER',
      joinedDate: (data['joinedDate'] as Timestamp?)?.toDate() ??
                  (data['createdAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
      isPro: data['isPro'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'isPro': isPro,
      'joinedDate': Timestamp.fromDate(joinedDate),
    };
  }

  bool get isValid => id.isNotEmpty && (name.isNotEmpty || email.isNotEmpty);
}

/// Stats for the profile screen
class UserStats {
  final int captures;
  final int rolls;
  final int likes;

  UserStats({
    this.captures = 0,
    this.rolls = 0,
    this.likes = 0,
  });
}

/// Provider to manage User Profile state with Firestore sync
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  UserProfileNotifier(this._prefs) : super(UserProfile.empty()) {
    _initProfile();
  }

  Future<void> _initProfile() async {
    if (_isInitialized) return;

    final user = _auth.currentUser;
    if (user != null) {
      await _loadProfileFromFirestore(user.uid);
    } else {
      // No user logged in - show empty profile
      state = UserProfile.empty();
    }
    _isInitialized = true;
  }

  /// Load profile directly from Firestore for a specific user
  Future<void> _loadProfileFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final profile = UserProfile.fromFirestore(userId, doc.data()!);
        state = profile;
        _syncToPrefs(profile);
      } else {
        // User document doesn't exist - create it
        final user = _auth.currentUser;
        if (user != null) {
          final initialProfile = UserProfile(
            id: userId,
            name: user.displayName ?? _extractNameFromEmail(user.email ?? ''),
            email: user.email ?? '',
            membershipStatus: 'FREE MEMBER',
            joinedDate: DateTime.now(),
          );
          await _firestore.collection('users').doc(userId).set(initialProfile.toFirestore());
          state = initialProfile;
          _syncToPrefs(initialProfile);
        }
      }
    } catch (e) {
      print('Error loading profile from Firestore: $e');
      // Fall back to auth user data
      final user = _auth.currentUser;
      if (user != null) {
        state = UserProfile(
          id: user.uid,
          name: user.displayName ?? _extractNameFromEmail(user.email ?? ''),
          email: user.email ?? '',
          membershipStatus: 'FREE MEMBER',
          joinedDate: DateTime.now(),
        );
      } else {
        state = UserProfile.empty();
      }
    }
  }

  /// Extract a display name from email (e.g., "john.doe@email.com" -> "John Doe")
  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return '';
    final localPart = email.split('@').first;
    final parts = localPart.split(RegExp(r'[._-]'));
    return parts.map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '').join(' ');
  }

  /// Public method to refresh user profile from Firestore
  /// Called after login to ensure fresh user data is loaded
  Future<void> refreshProfile() async {
    _isInitialized = false; // Allow re-initialization
    final user = _auth.currentUser;
    if (user != null) {
      await _loadProfileFromFirestore(user.uid);
    } else {
      state = UserProfile.empty();
    }
    _isInitialized = true;
  }

  void _syncToPrefs(UserProfile profile) {
    _prefs.setString('user_id', profile.id);
    _prefs.setString('user_name', profile.name);
    _prefs.setString('user_email', profile.email);
    _prefs.setBool('is_pro', profile.isPro);
    _prefs.setInt('joined_date', profile.joinedDate.millisecondsSinceEpoch);
  }

  Future<void> setEmail(String email) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'email': email});
    }
    _prefs.setString('user_email', email);
    state = state.copyWith(email: email);
  }

  Future<void> setName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'name': name});
    }
    _prefs.setString('user_name', name);
    state = state.copyWith(name: name);
  }

  Future<void> upgradeToPro() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'isPro': true});
    }
    _prefs.setBool('is_pro', true);
    state = state.copyWith(isPro: true, membershipStatus: 'ROYAL MEMBER');
  }

  /// Sign out - clear all user data and reset to empty state
  void signOut() {
    // Clear SharedPreferences
    _prefs.setBool('is_authenticated', false);
    _prefs.remove('user_id');
    _prefs.remove('user_name');
    _prefs.remove('user_email');
    _prefs.remove('is_pro');
    _prefs.remove('joined_date');

    // Reset state to empty profile
    state = UserProfile.empty();
    _isInitialized = false;
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserProfileNotifier(prefs);
});

/// Provider for dynamic user stats - Now fully real
final dynamicUserStatsProvider = StreamProvider<UserStats>((ref) async* {
  // Helper to fetch current stats
  Future<UserStats> fetchCurrentStats() async {
    final photos = await PhotoStorageService.instance.getAllPhotos();
    final likedCameras = CameraRepository.getFavoriteCameras();
    final likedPresets = PresetRepository.getFavoritePresets();
    
    return UserStats(
      captures: photos.length,
      rolls: photos.length > 0 ? (photos.length / 24).ceil() : 0,
      likes: likedCameras.length + likedPresets.length,
    );
  }

  // 1. Emit initial state
  yield await fetchCurrentStats();

  // 2. Create a combined stream for monitoring changes
  final controller = StreamController<void>();
  
  // Listen to both photo storage and camera repository changes
  final photoSub = PhotoStorageService.instance.photosChanged.listen((_) => controller.add(null));
  final favoriteSub = CameraRepository.favoritesChanged.listen((_) => controller.add(null));
  final presetSub = PresetRepository.favoritesChanged.listen((_) => controller.add(null));
  
  // Ensure cleanup on disposal
  ref.onDispose(() {
    photoSub.cancel();
    favoriteSub.cancel();
    presetSub.cancel();
    controller.close();
  });

  // 3. React to any change
  await for (final _ in controller.stream) {
    yield await fetchCurrentStats();
  }
});

/// Provider for most recent photos (reactive)
final recentPhotosProvider = StreamProvider<List<PhotoInfo>>((ref) async* {
  // Initial fetch
  yield await PhotoStorageService.instance.getAllPhotos();

  // Listen for changes
  await for (final _ in PhotoStorageService.instance.photosChanged) {
    yield await PhotoStorageService.instance.getAllPhotos();
  }
});
