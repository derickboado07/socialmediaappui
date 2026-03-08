import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/post_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  await PostService.instance.init();
  runApp(const FaithConnectApp());
}

class FaithConnectApp extends StatelessWidget {
  const FaithConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaithConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64B5F6), // Light Blue
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF5C5C5C)),
          titleTextStyle: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.grey.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C5C5C)),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/edit_profile': (_) => const EditProfileScreen(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        child: const Icon(Icons.person),
        tooltip: 'Login / Register',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP APP BAR
            const TopAppBarSection(),

            // DAILY VERSE SECTION
            const DailyVerseSection(),

            const SizedBox(height: 16),

            // CREATE POST SECTION
            const CreatePostSection(),

            const SizedBox(height: 16),

            // FEED POSTS SECTION
            FeedPostsSection(),

            const SizedBox(height: 16),

            // REELS PREVIEW SECTION
            const ReelsPreviewSection(),

            const SizedBox(height: 16),

            // MARKETPLACE PREVIEW SECTION
            const MarketplacePreviewSection(),

            const SizedBox(height: 16),

            // MUSIC SECTION
            const MusicSection(),

            const SizedBox(height: 16),

            // PROFILE PREVIEW SECTION
            const ProfilePreviewSection(),

            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// ============================================
// TOP APP BAR SECTION
// ============================================
class TopAppBarSection extends StatelessWidget {
  const TopAppBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // App Logo - Cross inspired
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5E6B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // App Name
          const Text(
            'FaithConnect',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Icons
          _buildIconButton(context, Icons.search),
          _buildIconButton(context, Icons.notifications_outlined),
          _buildIconButton(context, Icons.message_outlined),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: icon == Icons.message_outlined
            ? () => Navigator.pushNamed(context, '/login')
            : null,
        icon: Icon(icon, size: 24),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

// ============================================
// DAILY VERSE SECTION
// ============================================
class DailyVerseSection extends StatelessWidget {
  const DailyVerseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Container(
              color: const Color(0xFFF5E6B3),
              child: const Center(
                child: Icon(
                  Icons.landscape,
                  size: 80,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
            // Dark Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '✝ DAILY VERSE',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '"For God so loved the world that He gave His only begotten Son, that whoever believes in Him should not perish but have everlasting life."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '— John 3:16',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildVerseButton(Icons.share_outlined, 'Share'),
                      const SizedBox(width: 16),
                      _buildVerseButton(Icons.bookmark_border, 'Save'),
                      const SizedBox(width: 16),
                      _buildVerseButton(Icons.self_improvement, 'Reflect'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CREATE POST SECTION
// ============================================
class CreatePostSection extends StatelessWidget {
  const CreatePostSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture with user's image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              image: const DecorationImage(
                image: AssetImage('../Profile.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text Field Placeholder
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Share your testimony...',
                style: TextStyle(color: Color(0xFF999999), fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostIconsRow extends StatelessWidget {
  const CreatePostIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPostIcon(Icons.photo_library_outlined, 'Photo'),
          _buildPostIcon(Icons.videocam_outlined, 'Video'),
          _buildPostIcon(Icons.music_note_outlined, 'Music'),
          _buildPostIcon(Icons.pan_tool_outlined, 'Prayer'),
        ],
      ),
    );
  }

  Widget _buildPostIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6B3).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================
// FEED POSTS SECTION
// ============================================
class FeedPostsSection extends StatelessWidget {
  FeedPostsSection({super.key});

  final List<Map<String, dynamic>> posts = [
    {
      'name': 'Denmar Curtivo',
      'time': '2 hours ago',
      'content':
          'Had an amazing worship session this morning! God\'s presence was so real in the room. 🙏✨ #worship #faith #blessed',
      'profileColor': const Color(0xFFE8D5B7),
    },
    {
      'name': 'Ps. Peter Tanchi',
      'time': '4 hours ago',
      'content':
          'Remember, God has not given us a spirit of fear, but of power, love, and a sound mind. - 2 Timothy 1:7',
      'profileColor': const Color(0xFFD4C4A8),
    },
    {
      'name': 'Mharc Cardenas',
      'time': '6 hours ago',
      'content':
          'Join us this Sunday for a powerful message on "Walking in Faith". Stream live at 10 AM!',
      'profileColor': const Color(0xFFC9B896),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: posts.map((post) => PostCard(post: post)).toList());
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Profile Picture
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: post['profileColor'] as Color,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              // Name and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      post['time'] as String,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.more_horiz, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            post['content'] as String,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 16),
          // Christian Reactions
          Row(
            children: [
              _buildReaction(Icons.thumb_up, 'Amen', const Color(0xFFD4AF37)),
              const SizedBox(width: 16),
              _buildReaction(Icons.pan_tool, 'Pray', const Color(0xFF8B9DC3)),
              const SizedBox(width: 16),
              _buildReaction(
                Icons.music_note,
                'Worship',
                const Color(0xFF9ACD32),
              ),
              const SizedBox(width: 16),
              _buildReaction(Icons.favorite, 'Love', const Color(0xFFE57373)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.chat_bubble_outline, 'Comment'),
              _buildActionButton(Icons.share_outlined, 'Share'),
              _buildActionButton(Icons.bookmark_border, 'Save'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReaction(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF888888)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================
// REELS PREVIEW SECTION
// ============================================
class ReelsPreviewSection extends StatelessWidget {
  const ReelsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Reels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildReelThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReelThumbnail(int index) {
    final colors = [
      const Color(0xFFF5E6B3),
      const Color(0xFFE8D5B7),
      const Color(0xFFD4C4A8),
      const Color(0xFFC9B896),
      const Color(0xFFDEC9A3),
    ];

    final names = [
      '@sarah_worship',
      '@pastor_john',
      '@grace_ministries',
      '@faith_talks',
      '@bible_study',
    ];

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Thumbnail
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 50,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Username overlay
          Positioned(
            bottom: 12,
            left: 8,
            right: 8,
            child: Text(
              names[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Amen icon overlay
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 14,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// MARKETPLACE PREVIEW SECTION
// ============================================
class MarketplacePreviewSection extends StatelessWidget {
  const MarketplacePreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Marketplace',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: [
              _buildProductCard(
                'Christian T-Shirt',
                '₱150.00',
                'assets/Christian T-shrit.webp',
              ),
              _buildProductCard(
                'Bible Cover',
                '₱200.00',
                'assets/Bible cover.jpg',
              ),
              _buildProductCard(
                'Worship Journal',
                '₱179.00',
                'assets/worship journal.webp',
              ),
              _buildProductCard(
                'Prayer Beads',
                '₱100.00',
                'assets/prayerbeeds.webp',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String title, String price, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: const Text(
                      'View',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// MUSIC SECTION
// ============================================
class MusicSection extends StatelessWidget {
  const MusicSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Worship Music',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildMusicCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMusicCard(int index) {
    final titles = [
      'Goodness of God',
      'Way Maker',
      'Great Are You Lord',
      'What A Beautiful Name',
      'Holy Spirit',
    ];
    final artists = [
      'Bethel Music',
      'Sinach',
      'Leeland',
      'Hillsong Worship',
      'Bryan & Katie Torwalt',
    ];

    final colors = [
      const Color(0xFFD4AF37),
      const Color(0xFFC9B896),
      const Color(0xFFB8A57A),
      const Color(0xFFA68B5B),
      const Color(0xFF8B7355),
    ];

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.album, size: 50, color: Colors.white),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Song Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  artists[index],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PROFILE PREVIEW SECTION
// ============================================
class ProfilePreviewSection extends StatelessWidget {
  const ProfilePreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cover Photo
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5E6B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Icons.landscape, size: 40, color: Colors.white),
            ),
          ),
          // Profile Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64B5F6),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Profile.jpg',
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Column(
                    children: [
                      const Text(
                        'Mark Frederick Boado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Child of God • Worship Leader',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sharing my faith journey one post at a time ✝️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatColumn(number: '2.5K', label: 'Followers'),
                          Container(
                            height: 30,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: const Color(0xFFE0E0E0),
                          ),
                          _StatColumn(number: '890', label: 'Following'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

// ============================================
// BOTTOM NAVIGATION BAR
// ============================================
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', true),
              _buildNavItem(context, Icons.play_circle_outline, 'Reels', false),
              _buildNavItem(context, Icons.auto_stories, 'Verse', false),
              _buildNavItem(
                context,
                Icons.storefront_outlined,
                'Market',
                false,
              ),
              _buildNavItem(context, Icons.music_note_outlined, 'Music', false),
              _buildNavItem(context, Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {
        if (label == 'Profile') {
          Navigator.pushNamed(context, '/profile');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
