
//import 'dart:convert';
import 'package:api_flutter/pages/posts/create_post_screen.dart';
import 'package:api_flutter/pages/posts/detail_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/post_model.dart';
import 'package:api_flutter/services/post_service.dart';
// import 'package:api_flutter/pages/posts/detail_posts_screen.dart';
// import 'package:api_flutter/pages/posts/create_post_screen.dart';

class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState();
}

class _ListPostScreenState extends State<ListPostScreen> {
  late Future<PostModel> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = PostService.listPosts();
  }

  void _refreshPosts() {
    setState(() {
      _futurePosts = PostService.listPosts();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }

    if (date is String) {
      final d = DateTime.tryParse(date);
      if (d != null) {
        return '${d.day}/${d.month}/${d.year}';
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        actions: [
          IconButton(onPressed: _refreshPosts, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
              if (result == true) _refreshPosts();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<PostModel>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data?.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                    if (result == true) _refreshPosts();
                  },
                  leading: post.foto != null && post.foto!.isNotEmpty
                      ? Image.network(
                          'http://127.0.0.1:8000/storage/${post.foto!}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.article),
                  title: Text(post.title ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.content != null && post.content!.isNotEmpty)
                        Text(
                          post.content!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        '${_formatDate(post.createdAt)} • ${post.status == 1 ? "Published" : "Draft"}',
                        style: TextStyle(
                          color: post.status == 1
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text('#${post.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}