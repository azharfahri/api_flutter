import 'package:api_flutter/pages/posts/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/post_model.dart';
import 'package:api_flutter/services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final DataPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = false;

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Post"),
        content: Text('Yakin ingin menghapus "${widget.post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await PostService.deletePost(widget.post.id!);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Post berhasil dihapus")));
      }
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title ?? 'Detail Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deletePost,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.post.foto != null && widget.post.foto!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'http://127.0.0.1:8000/storage/${widget.post.foto!}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(widget.post.status == 1 ? "Published" : "Draft"),
                backgroundColor: widget.post.status == 1
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
              ),
              if (widget.post.createdAt != null)
                Text(
                  _formatDate(widget.post.createdAt!),
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.content ?? 'Tidak ada konten',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPostScreen(post: widget.post),
            ),
          );
          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}