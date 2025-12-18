import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/news_article.dart';

/// NewsAPI Service (SubCPMK 2 - Public Data Integration)
/// Fetches environment/waste/recycling news from NewsAPI.org
class NewsService {
  /// Fetch environment news
  /// Keywords: environment, waste, recycling
  /// Returns top 3 articles
  Future<List<NewsArticle>> fetchEnvironmentNews() async {
    try {
      final uri = Uri.parse(ApiConfig.newsApiUrl).replace(
        queryParameters: {
          'q': 'environment OR waste OR recycling',
          'language': 'en',
          'sortBy': 'publishedAt',
          'pageSize': '3',
          'apiKey': ApiConfig.newsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'ok' && data['articles'] != null) {
          final List<dynamic> articlesJson = data['articles'];
          return articlesJson
              .map((json) => NewsArticle.fromJson(json))
              .toList();
        }
      }

      // Return empty list if failed
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }
}
