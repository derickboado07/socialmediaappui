import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  final TextEditingController _newPostCtrl = TextEditingController();
  List posts = [];
  Map<String, bool> _savedMap = {};

  void _toggleFollow(String email) async {
    final newState = await AuthService.instance.toggleFollow(email);
    setState(() => _isFollowing = newState);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFollowing ? 'Following' : 'Unfollowed')),
    );
  }

  @override
  void dispose() {
    _newPostCtrl.dispose();
    super.dispose();
  }

  void _shareProfile(String email) async {
    final url =
        'https://faithconnect.example.com/u/${Uri.encodeComponent(email)}';
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile link copied to clipboard')),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<AuthUser?>(
        valueListenable: AuthService.instance.currentUser,
        builder: (context, user, _) {
          if (user == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Not logged in'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            );
          }

          AuthService.instance.isFollowing(user.email).then((v) {
            if (!mounted) return;
            setState(() => _isFollowing = v);
          });
          // load posts for this user
          PostService.instance.getPostsForUser(user.email).then((p) {
            if (!mounted) return;
            setState(() {
              posts = p;
            });
            // load saved states
            final cur = AuthService.instance.currentUser.value;
            if (cur != null) {
              for (var post in p) {
                PostService.instance.isSaved(post.id, cur.id).then((saved) {
                  if (!mounted) return;
                  setState(() => _savedMap[post.id] = saved);
                });
              }
            }
          });

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF333333),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                  title: Text(user.name, style: const TextStyle(fontSize: 16)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF5E6B3)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.landscape,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await AuthService.instance.logout();
                      if (context.mounted)
                        Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFFE0E0E0),
                            child: (user.avatarUrl.isEmpty)
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 28),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      user.avatarUrl,
                                      fit: BoxFit.cover,
                                      width: 88,
                                      height: 88,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.email,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/edit_profile',
                                ),
                                child: const Text('Edit'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () => _shareProfile(user.email),
                                child: const Icon(Icons.share),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _StatColumn(number: '2.5K', label: 'Followers'),
                              const SizedBox(width: 16),
                              _StatColumn(number: '890', label: 'Following'),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _toggleFollow(user.email),
                            child: Text(_isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Create post pill + quick post controls
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(
                                    context,
                                    '/create_post',
                                  ).then((_) {
                                    PostService.instance
                                        .getPostsForUser(user.email)
                                        .then((p) {
                                          setState(() => posts = p);
                                        });
                                  }),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFFD4AF37),
                                      child: (user.avatarUrl.isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : ClipOval(
                                              child: Image.network(
                                                user.avatarUrl,
                                                width: 28,
                                                height: 28,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Share your testimony...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final text = _newPostCtrl.text.trim();
                              if (text.isEmpty) return;
                              await PostService.instance.addPost(
                                user.id,
                                user.email,
                                text,
                              );
                              _newPostCtrl.clear();
                              final p = await PostService.instance
                                  .getPostsForUser(user.email);
                              setState(() => posts = p);
                            },
                            child: const Text('Post'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(
                                  context,
                                  '/create_post',
                                ).then((_) {
                                  PostService.instance
                                      .getPostsForUser(user.email)
                                      .then((p) {
                                        if (!mounted) return;
                                        setState(() => posts = p);
                                      });
                                }),
                            icon: const Icon(Icons.photo_library),
                            tooltip: 'Create post with media',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.phone.isEmpty
                                    ? 'No phone provided.'
                                    : user.phone,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Gender: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user.gender.isEmpty ? '—' : user.gender),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'DOB: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user.dob ?? '—'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'Bio',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(user.bio.isEmpty ? 'No bio yet.' : user.bio),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(post.timestamp),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Text(
                              post.content,
                              style: const TextStyle(fontSize: 14, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),

                            if (post.mediaUrl != null) ...[
                              const SizedBox(height: 8),
                              post.mediaType == 'image'
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        post.mediaUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.videocam,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              post.mediaUrl!.split('/').last,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                _ReactionButton(
                                  label: 'Amen',
                                  icon: Icons.thumb_up_alt_outlined,
                                  count: post.reactions['Amen']?.length ?? 0,
                                  active:
                                      AuthService.instance.currentUser.value !=
                                          null &&
                                      (post.reactions['Amen']?.contains(
                                            AuthService
                                                .instance
                                                .currentUser
                                                .value!
                                                .id,
                                          ) ??
                                          false),
                                  onTap: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleReaction(
                                      post.id,
                                      'Amen',
                                      cur.id,
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _ReactionButton(
                                  label: 'Pray',
                                  icon: Icons.self_improvement,
                                  count: post.reactions['Pray']?.length ?? 0,
                                  active:
                                      AuthService.instance.currentUser.value !=
                                          null &&
                                      (post.reactions['Pray']?.contains(
                                            AuthService
                                                .instance
                                                .currentUser
                                                .value!
                                                .id,
                                          ) ??
                                          false),
                                  onTap: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleReaction(
                                      post.id,
                                      'Pray',
                                      cur.id,
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _ReactionButton(
                                  label: 'Worship',
                                  icon: Icons.music_note,
                                  count: post.reactions['Worship']?.length ?? 0,
                                  active:
                                      AuthService.instance.currentUser.value !=
                                          null &&
                                      (post.reactions['Worship']?.contains(
                                            AuthService
                                                .instance
                                                .currentUser
                                                .value!
                                                .id,
                                          ) ??
                                          false),
                                  onTap: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleReaction(
                                      post.id,
                                      'Worship',
                                      cur.id,
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _ReactionButton(
                                  label: 'Love',
                                  icon: Icons.favorite_border,
                                  count: post.reactions['Love']?.length ?? 0,
                                  active:
                                      AuthService.instance.currentUser.value !=
                                          null &&
                                      (post.reactions['Love']?.contains(
                                            AuthService
                                                .instance
                                                .currentUser
                                                .value!
                                                .id,
                                          ) ??
                                          false),
                                  onTap: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleReaction(
                                      post.id,
                                      'Love',
                                      cur.id,
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _ReactionButton(
                                  label: 'Praise',
                                  icon: Icons.emoji_emotions,
                                  count: post.reactions['Praise']?.length ?? 0,
                                  active:
                                      AuthService.instance.currentUser.value !=
                                          null &&
                                      (post.reactions['Praise']?.contains(
                                            AuthService
                                                .instance
                                                .currentUser
                                                .value!
                                                .id,
                                          ) ??
                                          false),
                                  onTap: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleReaction(
                                      post.id,
                                      'Praise',
                                      cur.id,
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                ),

                                const Spacer(),

                                IconButton(
                                  onPressed: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to react'),
                                        ),
                                      );
                                      return;
                                    }
                                    await showModalBottomSheet<void>(
                                      context: context,
                                      builder: (ctx) {
                                        return SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.thumb_up,
                                                ),
                                                title: const Text('Amen'),
                                                onTap: () async {
                                                  await PostService.instance
                                                      .toggleReaction(
                                                        post.id,
                                                        'Amen',
                                                        cur.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                  final p = await PostService
                                                      .instance
                                                      .getPostsForUser(
                                                        user.email,
                                                      );
                                                  if (!mounted) return;
                                                  setState(() => posts = p);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.self_improvement,
                                                ),
                                                title: const Text('Pray'),
                                                onTap: () async {
                                                  await PostService.instance
                                                      .toggleReaction(
                                                        post.id,
                                                        'Pray',
                                                        cur.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                  final p = await PostService
                                                      .instance
                                                      .getPostsForUser(
                                                        user.email,
                                                      );
                                                  if (!mounted) return;
                                                  setState(() => posts = p);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.music_note,
                                                ),
                                                title: const Text('Worship'),
                                                onTap: () async {
                                                  await PostService.instance
                                                      .toggleReaction(
                                                        post.id,
                                                        'Worship',
                                                        cur.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                  final p = await PostService
                                                      .instance
                                                      .getPostsForUser(
                                                        user.email,
                                                      );
                                                  if (!mounted) return;
                                                  setState(() => posts = p);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.favorite,
                                                ),
                                                title: const Text('Love'),
                                                onTap: () async {
                                                  await PostService.instance
                                                      .toggleReaction(
                                                        post.id,
                                                        'Love',
                                                        cur.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                  final p = await PostService
                                                      .instance
                                                      .getPostsForUser(
                                                        user.email,
                                                      );
                                                  if (!mounted) return;
                                                  setState(() => posts = p);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.emoji_emotions,
                                                ),
                                                title: const Text('Praise'),
                                                onTap: () async {
                                                  await PostService.instance
                                                      .toggleReaction(
                                                        post.id,
                                                        'Praise',
                                                        cur.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                  final p = await PostService
                                                      .instance
                                                      .getPostsForUser(
                                                        user.email,
                                                      );
                                                  if (!mounted) return;
                                                  setState(() => posts = p);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.thumb_up_outlined),
                                  tooltip: 'React',
                                ),

                                IconButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) =>
                                          _CommentsSheet(postId: post.id),
                                    );
                                    final p = await PostService.instance
                                        .getPostsForUser(user.email);
                                    setState(() => posts = p);
                                  },
                                  icon: const Icon(Icons.comment_outlined),
                                ),

                                IconButton(
                                  onPressed: () async {
                                    final cur =
                                        AuthService.instance.currentUser.value;
                                    if (cur == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login to save posts'),
                                        ),
                                      );
                                      return;
                                    }
                                    await PostService.instance.toggleSave(
                                      post.id,
                                      cur.id,
                                    );
                                    final saved = await PostService.instance
                                        .isSaved(post.id, cur.id);
                                    setState(() => _savedMap[post.id] = saved);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          saved ? 'Saved' : 'Removed',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    _savedMap[post.id] == true
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () async {
                                    final content =
                                        '${post.content}\n— from ${user.name}';
                                    await Clipboard.setData(
                                      ClipboardData(text: content),
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Post copied to clipboard',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: posts.length),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String number;
  final String label;

  const _StatColumn({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              count > 0 ? '$label ($count)' : label,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _ctrl = TextEditingController();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final p = await PostService.instance.getById(widget.postId);
    if (!mounted) return;
    setState(() => _comments = p?.comments ?? []);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 12,
        right: 12,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 220,
            child: _comments.isEmpty
                ? const Center(child: Text('No comments yet'))
                : ListView.separated(
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final c = _comments[i];
                      return ListTile(
                        title: Text(c.author),
                        subtitle: Text(c.text),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final text = _ctrl.text.trim();
                  if (text.isEmpty) return;
                  final user = AuthService.instance.currentUser.value;
                  if (user == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login to comment')),
                    );
                    return;
                  }
                  await PostService.instance.addComment(
                    widget.postId,
                    user.id,
                    user.email,
                    text,
                  );
                  _ctrl.clear();
                  await _loadComments();
                },
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
