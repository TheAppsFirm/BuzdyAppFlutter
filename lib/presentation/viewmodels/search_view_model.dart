import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../screens/search/models/news_article.dart';
import '../screens/dashboard/feed/model/youtubeModel.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _service = SearchService();
  String lastQuery = '';

  bool isLoading = false;
  List<Item> videoResults = [];
  List<NewsArticle> newsResults = [];

  void clear() {
    lastQuery = '';
    videoResults = [];
    newsResults = [];
    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    lastQuery = query;
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.searchYouTube(query),
        _service.searchNews(query),
      ]);
      videoResults = results[0] as List<Item>;
      newsResults = results[1] as List<NewsArticle>;
    } catch (e) {
      debugPrint('Search error: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
