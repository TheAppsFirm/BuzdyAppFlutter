class GoogleResult {
  final String title;
  final String link;
  final String snippet;
  final String? imageUrl;

  GoogleResult({required this.title, required this.link, required this.snippet, this.imageUrl});

  factory GoogleResult.fromJson(Map<String, dynamic> json) {
    String? image;
    if (json['pagemap'] != null && json['pagemap']['cse_image'] != null) {
      final images = json['pagemap']['cse_image'] as List<dynamic>;
      if (images.isNotEmpty) image = images.first['src'] as String?;
    }
    return GoogleResult(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
      imageUrl: image,
    );
  }
}
