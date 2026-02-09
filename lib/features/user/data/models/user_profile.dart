import 'package:cloud_firestore/cloud_firestore.dart';

/// Complete user profile model for Firebase storage
/// Contains all onboarding preferences and user data
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  // Onboarding preferences
  final String? whyFilm;           // warmth, imperfection, ritual, nostalgia
  final String? favoriteEra;       // 70s, 80s, 90s, 2000s
  final List<String> subjects;     // portraits, streets, landscapes, nightlife, moments, experimental
  final String workflow;           // camera_explorer, quick_presets, balanced
  final String aspectRatio;        // 3:4, 1:1, 16:9
  final List<String> toolkitCameraIds;

  // App usage stats
  final int photosShot;
  final int filmsUsed;
  final String? favoriteFilm;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool hasCompletedOnboarding;
  final bool isPro;

  // Settings sync
  final String themeMode;
  final bool hapticFeedback;
  final bool gridOverlay;
  final bool saveOriginal;

  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.whyFilm,
    this.favoriteEra,
    this.subjects = const [],
    this.workflow = 'balanced',
    this.aspectRatio = '3:4',
    this.toolkitCameraIds = const [],
    this.photosShot = 0,
    this.filmsUsed = 0,
    this.favoriteFilm,
    required this.createdAt,
    required this.lastActiveAt,
    this.hasCompletedOnboarding = false,
    this.isPro = false,
    this.themeMode = 'dark',
    this.hapticFeedback = true,
    this.gridOverlay = true,
    this.saveOriginal = false,
  });

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      whyFilm: data['whyFilm'] as String?,
      favoriteEra: data['favoriteEra'] as String?,
      subjects: List<String>.from(data['subjects'] ?? []),
      workflow: data['workflow'] as String? ?? 'balanced',
      aspectRatio: data['aspectRatio'] as String? ?? '3:4',
      toolkitCameraIds: List<String>.from(data['toolkitCameraIds'] ?? []),
      photosShot: data['photosShot'] as int? ?? 0,
      filmsUsed: data['filmsUsed'] as int? ?? 0,
      favoriteFilm: data['favoriteFilm'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] as bool? ?? false,
      isPro: data['isPro'] as bool? ?? false,
      themeMode: data['themeMode'] as String? ?? 'dark',
      hapticFeedback: data['hapticFeedback'] as bool? ?? true,
      gridOverlay: data['gridOverlay'] as bool? ?? true,
      saveOriginal: data['saveOriginal'] as bool? ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'whyFilm': whyFilm,
      'favoriteEra': favoriteEra,
      'subjects': subjects,
      'workflow': workflow,
      'aspectRatio': aspectRatio,
      'toolkitCameraIds': toolkitCameraIds,
      'photosShot': photosShot,
      'filmsUsed': filmsUsed,
      'favoriteFilm': favoriteFilm,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'isPro': isPro,
      'themeMode': themeMode,
      'hapticFeedback': hapticFeedback,
      'gridOverlay': gridOverlay,
      'saveOriginal': saveOriginal,
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? whyFilm,
    String? favoriteEra,
    List<String>? subjects,
    String? workflow,
    String? aspectRatio,
    List<String>? toolkitCameraIds,
    int? photosShot,
    int? filmsUsed,
    String? favoriteFilm,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? hasCompletedOnboarding,
    bool? isPro,
    String? themeMode,
    bool? hapticFeedback,
    bool? gridOverlay,
    bool? saveOriginal,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      whyFilm: whyFilm ?? this.whyFilm,
      favoriteEra: favoriteEra ?? this.favoriteEra,
      subjects: subjects ?? this.subjects,
      workflow: workflow ?? this.workflow,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      toolkitCameraIds: toolkitCameraIds ?? this.toolkitCameraIds,
      photosShot: photosShot ?? this.photosShot,
      filmsUsed: filmsUsed ?? this.filmsUsed,
      favoriteFilm: favoriteFilm ?? this.favoriteFilm,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isPro: isPro ?? this.isPro,
      themeMode: themeMode ?? this.themeMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      gridOverlay: gridOverlay ?? this.gridOverlay,
      saveOriginal: saveOriginal ?? this.saveOriginal,
    );
  }

  /// Create empty profile for new user
  factory UserProfile.empty(String userId) {
    final now = DateTime.now();
    return UserProfile(
      id: userId,
      createdAt: now,
      lastActiveAt: now,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, workflow: $workflow, era: $favoriteEra, subjects: $subjects)';
  }
}

/// Onboarding data transfer object
/// Used to collect data during onboarding flow before saving
class OnboardingData {
  String? whyFilm;
  String? favoriteEra;
  List<String> subjects;
  String workflow;
  String aspectRatio;
  List<String> toolkitCameraIds;

  OnboardingData({
    this.whyFilm,
    this.favoriteEra,
    this.subjects = const [],
    this.workflow = 'balanced',
    this.aspectRatio = '3:4',
    this.toolkitCameraIds = const [],
  });

  /// Convert to map for updating UserProfile
  Map<String, dynamic> toMap() {
    return {
      'whyFilm': whyFilm,
      'favoriteEra': favoriteEra,
      'subjects': subjects,
      'workflow': workflow,
      'aspectRatio': aspectRatio,
      'toolkitCameraIds': toolkitCameraIds,
      'hasCompletedOnboarding': true,
      'lastActiveAt': Timestamp.now(),
    };
  }
}
