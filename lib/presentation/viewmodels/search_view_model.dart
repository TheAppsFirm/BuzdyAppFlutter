import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../screens/search/models/google_result.dart';
import '../screens/search/models/news_article.dart';
import '../screens/dashboard/feed/model/youtubeModel.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _service = SearchService();

  bool isLoading = false;
  List<GoogleResult> webResults = [];
  List<Item> videoResults = [];
  List<NewsArticle> newsResults = [];

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.searchGoogle(query),
        _service.searchYouTube(query),
        _service.searchNews(query),
      ]);
      webResults = results[0] as List<GoogleResult>;
      videoResults = results[1] as List<Item>;
      newsResults = results[2] as List<NewsArticle>;
    } catch (e) {
      debugPrint('Search error: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
