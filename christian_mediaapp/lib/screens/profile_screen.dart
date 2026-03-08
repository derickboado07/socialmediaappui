import 'dart:io';
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

  void _toggleFollow(String email) async {
    await AuthService.instance.toggleFollow(email);
    setState(() => _isFollowing = AuthService.instance.isFollowing(email));
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

          var posts = PostService.instance.getPostsForUser(user.email);
          _isFollowing = AuthService.instance.isFollowing(user.email);

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
                            child: user.avatarPath.isEmpty
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 28),
                                  )
                                : ClipOval(
                                    child: Image.file(
                                      File(user.avatarPath),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newPostCtrl,
                              decoration: const InputDecoration(
                                hintText: 'What\'s on your heart?',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final text = _newPostCtrl.text.trim();
                              if (text.isEmpty) return;
                              await PostService.instance.addPost(
                                user.email,
                                text,
                              );
                              _newPostCtrl.clear();
                              setState(() {
                                posts = PostService.instance.getPostsForUser(
                                  user.email,
                                );
                              });
                            },
                            child: const Text('Post'),
                          ),
                        ],
                      ),
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
                  final text = posts[index].content;
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
                                const Text(
                                  '2h',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(text),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.thumb_up_outlined),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.comment_outlined),
                                ),
                                IconButton(
                                  onPressed: () {},
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
