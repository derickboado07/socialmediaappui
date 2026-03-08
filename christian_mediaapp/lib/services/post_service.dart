import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Post {
  final String id;
  final String authorEmail;
  final String content;
  final String timestamp;

  Post({
    required this.id,
    required this.authorEmail,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': authorEmail,
    'content': content,
    'ts': timestamp,
  };

  static Post fromJson(Map<String, dynamic> j) => Post(
    id: j['id'],
    authorEmail: j['author'],
    content: j['content'],
    timestamp: j['ts'],
  );
}

class PostService {
  PostService._internal();
  static final PostService instance = PostService._internal();

  final List<Post> _posts = [];

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('posts');
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        _posts.clear();
        _posts.addAll(
          list.map((e) => Post.fromJson(Map<String, dynamic>.from(e))),
        );
      } catch (_) {}
    }
  }

  List<Post> getPostsForUser(String email) =>
      _posts.where((p) => p.authorEmail == email).toList();

  Future<void> addPost(String authorEmail, String content) async {
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorEmail: authorEmail,
      content: content,
      timestamp: DateTime.now().toIso8601String(),
    );
    _posts.insert(0, post);
    await _save();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final enc = json.encode(_posts.map((p) => p.toJson()).toList());
    await sp.setString('posts', enc);
  }
}
