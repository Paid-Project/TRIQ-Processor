import 'package:flutter/material.dart';
import 'package:manager/widgets/common/common_cached_image.dart';

class ImagePreviewDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? messageContent;

  const ImagePreviewDialog({super.key, required this.imageUrls, this.initialIndex = 0, this.messageContent});

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: Text('${_currentIndex + 1} of ${widget.imageUrls.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Image viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Hero(
                      tag: 'chat_image_${widget.imageUrls[index]}',
                      child: CommonCachedImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.contain,
                        errorColor: Colors.grey[800],
                        errorIconSize: 60,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Message content (if any)
          if (widget.messageContent != null && widget.messageContent!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Text(widget.messageContent!, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
            ),
          // Thumbnail strip (if multiple images)
          if (widget.imageUrls.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Hero(
                          tag: 'chat_image_${widget.imageUrls[index]}',
                          child: CommonCachedImage(imageUrl: widget.imageUrls[index], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Show image preview dialog
void showImagePreviewDialog({required BuildContext context, required List<String> imageUrls, int initialIndex = 0, String? messageContent}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImagePreviewDialog(imageUrls: imageUrls, initialIndex: initialIndex, messageContent: messageContent),
      fullscreenDialog: true,
    ),
  );
}
