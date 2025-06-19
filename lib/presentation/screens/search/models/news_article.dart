class NewsArticle {
  final String title;
  final String url;
  final String? imageUrl;
  final String? source;

  NewsArticle({required this.title, required this.url, this.imageUrl, this.source});

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] as String?,
      source: json['source'] != null ? json['source']['name'] as String? : null,
    );
  }
}
