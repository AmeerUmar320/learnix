import 'package:flutter/material.dart';
import '../models/group_resource_model.dart';

class ImageViewerPage extends StatefulWidget {
  final List<GroupResourceModel> images;
  final int initialIndex;

  const ImageViewerPage({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.images[_currentIndex].fileName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
        },
        itemBuilder: (ctx, i) {
          final img = widget.images[i];
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 3.0,
            child: Center(
              child: Image.network(
                'http://192.168.100.28:5241${img.fileUrl}',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
