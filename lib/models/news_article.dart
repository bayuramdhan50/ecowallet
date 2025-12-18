class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? 'No description',
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String,
      sourceName: json['source']?['name'] as String?,
    );
  }
}
