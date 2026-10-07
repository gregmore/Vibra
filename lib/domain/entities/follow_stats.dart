/// Statistiche follower e following di un utente.
class FollowStats {
  const FollowStats({
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isFollower,
  });

  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isFollower;

  const FollowStats.empty()
    : followersCount = 0,
      followingCount = 0,
      isFollowing = false,
      isFollower = false;

  FollowStats copyWith({
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    bool? isFollower,
  }) {
    return FollowStats(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
    );
  }
}
