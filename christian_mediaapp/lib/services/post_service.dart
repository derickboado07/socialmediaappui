import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Comment {
  final String id;
  final String author;
  final String text;
  final String ts;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'ts': ts,
  };

  static Comment fromJson(Map<String, dynamic> j) =>
      Comment(id: j['id'], author: j['author'], text: j['text'], ts: j['ts']);
}

class Post {
  final String id;
  final String authorId;
  final String authorEmail;
  final String content;
  final String timestamp;
  final String? mediaUrl;
  final String? mediaType; // 'image' or 'video' or null
  final Map<String, List<String>>
  reactions; // reaction -> list of user ids/emails
  final List<Comment> comments;

  Post({
    required this.id,
    required this.authorId,
    required this.authorEmail,
    required this.content,
    required this.timestamp,
    this.mediaUrl,
    this.mediaType,
    Map<String, List<String>>? reactions,
    List<Comment>? comments,
  }) : reactions = reactions ?? {},
       comments = comments ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'author': authorEmail,
    'content': content,
    'ts': timestamp,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'reactions': reactions.map((k, v) => MapEntry(k, v)),
  };

  static Post fromJson(Map<String, dynamic> j) => Post(
    id: j['id'],
    authorId: j['authorId'],
    authorEmail: j['author'],
    content: j['content'],
    timestamp: j['ts'],
    mediaUrl: j['mediaUrl'],
    mediaType: j['mediaType'],
    reactions:
        (j['reactions'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        ) ??
        {},
  );
}

class PostService {
  PostService._internal();
  static final PostService instance = PostService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> init() async {
    // Nothing to cache locally; Firestore will be used.
    return;
  }

  Future<List<Post>> fetchFeed({int limit = 50}) async {
    final snap = await _db
        .collection('posts')
        .orderBy('ts', descending: true)
        .limit(limit)
        .get();
    final posts = snap.docs.map((d) => Post.fromJson(d.data())).toList();
    // load comments for each post
    for (var i = 0; i < posts.length; i++) {
      final p = posts[i];
      final cm = await _loadCommentsForPost(p.id);
      posts[i] = Post(
        id: p.id,
        authorId: p.authorId,
        authorEmail: p.authorEmail,
        content: p.content,
        timestamp: p.timestamp,
        mediaUrl: p.mediaUrl,
        mediaType: p.mediaType,
        reactions: p.reactions,
        comments: cm,
      );
    }
    return posts;
  }

  Future<Post?> getById(String id) async {
    final doc = await _db.collection('posts').doc(id).get();
    if (!doc.exists) return null;
    final p = Post.fromJson(doc.data()!);
    final comments = await _loadCommentsForPost(id);
    return Post(
      id: p.id,
      authorId: p.authorId,
      authorEmail: p.authorEmail,
      content: p.content,
      timestamp: p.timestamp,
      mediaUrl: p.mediaUrl,
      mediaType: p.mediaType,
      reactions: p.reactions,
      comments: comments,
    );
  }

  Future<String?> _uploadMedia(String postId, String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      final ref = _storage.ref().child('posts').child(postId).child('media');
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> addPost(
    String authorId,
    String authorEmail,
    String content, {
    String? mediaPath,
    String? mediaType,
  }) async {
    final docRef = _db.collection('posts').doc();
    final id = docRef.id;
    String? mediaUrl;
    if (mediaPath != null && mediaPath.isNotEmpty) {
      mediaUrl = await _uploadMedia(id, mediaPath.replaceFirst('file://', ''));
    }
    final post = Post(
      id: id,
      authorId: authorId,
      authorEmail: authorEmail,
      content: content,
      timestamp: DateTime.now().toIso8601String(),
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      comments: [],
    );
    await docRef.set(post.toJson());
  }

  Future<List<Comment>> _loadCommentsForPost(String postId) async {
    final snap = await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('ts')
        .get();
    return snap.docs.map((d) => Comment.fromJson(d.data())).toList();
  }

  Future<List<Post>> getPostsForUser(String email) async {
    final snap = await _db
        .collection('posts')
        .where('author', isEqualTo: email)
        .orderBy('ts', descending: true)
        .get();
    final posts = snap.docs.map((d) => Post.fromJson(d.data())).toList();
    for (var i = 0; i < posts.length; i++) {
      final cm = await _loadCommentsForPost(posts[i].id);
      posts[i] = Post(
        id: posts[i].id,
        authorId: posts[i].authorId,
        authorEmail: posts[i].authorEmail,
        content: posts[i].content,
        timestamp: posts[i].timestamp,
        mediaUrl: posts[i].mediaUrl,
        mediaType: posts[i].mediaType,
        reactions: posts[i].reactions,
        comments: cm,
      );
    }
    return posts;
  }

  Future<void> toggleReaction(
    String postId,
    String reaction,
    String userId,
  ) async {
    final docRef = _db.collection('posts').doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = Map<String, dynamic>.from(snap.data() ?? {});
      final reactions =
          (data['reactions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v as List)),
          ) ??
          {};
      final list = reactions[reaction] ?? <String>[];
      if (list.contains(userId)) {
        list.remove(userId);
      } else {
        list.add(userId);
      }
      reactions[reaction] = list;
      tx.update(docRef, {'reactions': reactions});
    });
  }

  Future<void> addComment(
    String postId,
    String authorId,
    String authorEmail,
    String text,
  ) async {
    final commentsRef = _db
        .collection('posts')
        .doc(postId)
        .collection('comments');
    final doc = commentsRef.doc();
    final comment = Comment(
      id: doc.id,
      author: authorEmail,
      text: text,
      ts: DateTime.now().toIso8601String(),
    );
    await doc.set(comment.toJson());
    await _db.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  Future<void> sharePost(String postId) async {
    // Leaving implementation to UI layer using share_plus; placeholder here
    return;
  }

  Future<bool> isSaved(String postId, String userId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('saved')
        .doc(postId)
        .get();
    return doc.exists;
  }

  Future<void> toggleSave(String postId, String userId) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('saved')
        .doc(postId);
    final snap = await docRef.get();
    if (snap.exists) {
      await docRef.delete();
    } else {
      await docRef.set({'savedAt': DateTime.now().toIso8601String()});
    }
  }
}
