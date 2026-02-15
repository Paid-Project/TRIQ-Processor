enum MediaType { image, video }

class MediaItem {
  final String url;
  final MediaType type;
  final String? thumbnailUrl;

  MediaItem({required this.url, required this.type, this.thumbnailUrl});
}
