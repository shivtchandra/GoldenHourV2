import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/photo_storage_service.dart';

/// Model for User Profile
class UserProfile {
  final String name;
  final String email;
  final String membershipStatus;
  final DateTime joinedDate;
  final bool isPro;

  UserProfile({
    required this.name,
    required this.email,
    required this.membershipStatus,
    required this.joinedDate,
    this.isPro = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? membershipStatus,
    DateTime? joinedDate,
    bool? isPro,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      joinedDate: joinedDate ?? this.joinedDate,
      isPro: isPro ?? this.isPro,
    );
  }
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

/// Provider to manage User Profile state
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;

  UserProfileNotifier(this._prefs)
      : super(UserProfile(
          name: _prefs.getString('user_name') ?? 'SHIVAT CHANDRA',
          email: _prefs.getString('user_email') ?? 'shivat@example.com',
          membershipStatus: _prefs.getBool('is_pro') == true ? 'ROYAL MEMBER' : 'FREE MEMBER',
          joinedDate: DateTime.fromMillisecondsSinceEpoch(
              _prefs.getInt('joined_date') ?? DateTime(2024, 1, 1).millisecondsSinceEpoch),
          isPro: _prefs.getBool('is_pro') ?? false,
        ));

  void setName(String name) {
    _prefs.setString('user_name', name);
    state = state.copyWith(name: name);
  }

  void upgradeToPro() {
    _prefs.setBool('is_pro', true);
    state = state.copyWith(isPro: true, membershipStatus: 'ROYAL MEMBER');
  }

  void signOut() {
    _prefs.clear();
    // In a real app, this would also clear auth tokens and navigate to login
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserProfileNotifier(prefs);
});

/// Provider for dynamic user stats
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final photos = await PhotoStorageService.instance.getAllPhotos();
  
  // Calculate rolls (approx 24 shots per roll)
  final captures = photos.length;
  final rolls = (captures / 24).ceil();
  
  // In our simple storage, we don't track 'likes' globally yet, 
  // but we can simulate it or count photos with a specific cameraId if we had favorites.
  // For now, let's use a mock 'likes' value or just use 0.
  
  return UserStats(
    captures: captures,
    rolls: rolls,
    likes: 142, // Keeping the user's mock value for now as it's not implemented in storage
  );
});
