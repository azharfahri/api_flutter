import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:api_flutter/models/post_model.dart';
import 'package:api_flutter/services/post_service.dart';

class EditPostScreen extends StatefulWidget {
  final DataPost post;
  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Uint8List? _imageBytes;
  String? _imageName;
  int _status = 1;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title ?? '');
    _contentController = TextEditingController(text: widget.post.content ?? '');
    _status = widget.post.status ?? 1;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
        _imageChanged = true;
      });
    }
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await PostService.updatePost(
      widget.post.id!,
      _titleController.text,
      _contentController.text,
      _status,
      _imageChanged ? _imageBytes : null,
      _imageChanged ? _imageName : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Post updated!' : 'Failed to update post'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Title required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 6,
                validator: (v) => v!.isEmpty ? "Content required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Published"),
                      value: 1,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Draft"),
                      value: 8,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : (widget.post.foto != null && 
                          widget.post.foto!.isNotEmpty)
                          ? Image.network(
                              'http://127.0.0.1:8000/storage/${widget.post.foto!}',
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await PostService.deletePost(widget.post.id!);
              if (!mounted) return;
              setState(() => _isLoading = false);
              Navigator.pop(context, 'deleted');
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}