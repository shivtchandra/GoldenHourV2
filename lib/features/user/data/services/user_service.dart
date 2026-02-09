import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Firebase service for user profile management
/// Handles all CRUD operations for user data
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection reference for users
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ============================================
  // CREATE / UPDATE
  // ============================================

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.id).set(
        profile.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw UserServiceException('Failed to save user profile: $e');
    }
  }

  /// Create new user profile on sign up
  Future<UserProfile> createUserProfile({
    required String userId,
    String? email,
    String? displayName,
  }) async {
    try {
      final profile = UserProfile.empty(userId).copyWith(
        email: email,
        displayName: displayName,
      );
      await saveUserProfile(profile);
      return profile;
    } catch (e) {
      throw UserServiceException('Failed to create user profile: $e');
    }
  }

  /// Save onboarding data to user profile
  Future<void> saveOnboardingData(OnboardingData data) async {
    final userId = currentUserId;
    if (userId == null) {
      throw UserServiceException('User not authenticated');
    }

    try {
      await _usersCollection.doc(userId).set(
        data.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw UserServiceException('Failed to save onboarding data: $e');
    }
  }

  /// Update specific fields in user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final userId = currentUserId;
    if (userId == null) {
      throw UserServiceException('User not authenticated');
    }

    try {
      updates['lastActiveAt'] = Timestamp.now();
      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw UserServiceException('Failed to update user profile: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      throw UserServiceException('Failed to get user profile: $e');
    }
  }

  /// Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return getUserProfile(userId);
  }

  /// Stream user profile for real-time updates
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Stream current user's profile
  Stream<UserProfile?> watchCurrentUserProfile() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }
    return watchUserProfile(userId);
  }

  // ============================================
  // STATS & ANALYTICS
  // ============================================

  /// Increment photo shot count
  Future<void> incrementPhotosShot() async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await _usersCollection.doc(userId).update({
        'photosShot': FieldValue.increment(1),
        'lastActiveAt': Timestamp.now(),
      });
    } catch (e) {
      // Silently fail for analytics - don't interrupt user experience
      print('Failed to increment photos shot: $e');
    }
  }

  /// Track film usage
  Future<void> trackFilmUsage(String filmId) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // Update film usage count and track favorite
      final profile = await getCurrentUserProfile();
      if (profile == null) return;

      // Simple favorite tracking - most used film
      await _usersCollection.doc(userId).update({
        'filmsUsed': FieldValue.increment(1),
        'lastUsedFilm': filmId,
        'lastActiveAt': Timestamp.now(),
      });

      // Update film usage stats in subcollection
      await _usersCollection
          .doc(userId)
          .collection('filmStats')
          .doc(filmId)
          .set({
        'filmId': filmId,
        'usageCount': FieldValue.increment(1),
        'lastUsed': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to track film usage: $e');
    }
  }

  /// Get user's favorite film based on usage
  Future<String?> getFavoriteFilm() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final stats = await _usersCollection
          .doc(userId)
          .collection('filmStats')
          .orderBy('usageCount', descending: true)
          .limit(1)
          .get();

      if (stats.docs.isEmpty) return null;
      return stats.docs.first.data()['filmId'] as String?;
    } catch (e) {
      print('Failed to get favorite film: $e');
      return null;
    }
  }

  /// Get film usage stats
  Future<Map<String, int>> getFilmUsageStats() async {
    final userId = currentUserId;
    if (userId == null) return {};

    try {
      final stats = await _usersCollection
          .doc(userId)
          .collection('filmStats')
          .get();

      return Map.fromEntries(
        stats.docs.map((doc) => MapEntry(
          doc.id,
          doc.data()['usageCount'] as int? ?? 0,
        )),
      );
    } catch (e) {
      print('Failed to get film usage stats: $e');
      return {};
    }
  }

  // ============================================
  // SETTINGS SYNC
  // ============================================

  /// Sync local settings to Firebase
  Future<void> syncSettings({
    String? themeMode,
    bool? hapticFeedback,
    bool? gridOverlay,
    bool? saveOriginal,
    String? workflow,
    String? aspectRatio,
    List<String>? toolkitCameraIds,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (themeMode != null) updates['themeMode'] = themeMode;
    if (hapticFeedback != null) updates['hapticFeedback'] = hapticFeedback;
    if (gridOverlay != null) updates['gridOverlay'] = gridOverlay;
    if (saveOriginal != null) updates['saveOriginal'] = saveOriginal;
    if (workflow != null) updates['workflow'] = workflow;
    if (aspectRatio != null) updates['aspectRatio'] = aspectRatio;
    if (toolkitCameraIds != null) updates['toolkitCameraIds'] = toolkitCameraIds;

    if (updates.isNotEmpty) {
      await updateUserProfile(updates);
    }
  }

  // ============================================
  // PRO STATUS
  // ============================================

  /// Update pro status
  Future<void> setProStatus(bool isPro) async {
    await updateUserProfile({'isPro': isPro});
  }

  /// Check if user is pro
  Future<bool> isProUser() async {
    final profile = await getCurrentUserProfile();
    return profile?.isPro ?? false;
  }

  // ============================================
  // DELETE
  // ============================================

  /// Delete user profile and all associated data
  Future<void> deleteUserProfile() async {
    final userId = currentUserId;
    if (userId == null) {
      throw UserServiceException('User not authenticated');
    }

    try {
      // Delete film stats subcollection
      final stats = await _usersCollection
          .doc(userId)
          .collection('filmStats')
          .get();

      for (final doc in stats.docs) {
        await doc.reference.delete();
      }

      // Delete main profile
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw UserServiceException('Failed to delete user profile: $e');
    }
  }
}

/// Custom exception for user service errors
class UserServiceException implements Exception {
  final String message;
  UserServiceException(this.message);

  @override
  String toString() => 'UserServiceException: $message';
}
