import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../screens/search/models/news_article.dart';
import '../screens/dashboard/feed/model/youtubeModel.dart';
import '../screens/search/models/law_info.dart';
import '../screens/search/models/google_result.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _service = SearchService();
  String lastQuery = '';

  bool isLoading = false;
  List<Item> videoResults = [];
  List<NewsArticle> newsResults = [];
  List<GoogleResult> googleResults = [];
  LawInfo? lawInfo;
  bool lawLoading = true;

  SearchViewModel() {
    loadLaw();
  }

  Future<void> loadLaw() async {
    lawLoading = true;
    notifyListeners();
    lawInfo = await _service.fetchLawInfo();
    lawLoading = false;
    notifyListeners();
  }

  Future<void> clear() async {
    lastQuery = '';
    videoResults = [];
    newsResults = [];
    googleResults = [];
    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    lastQuery = query;
    isLoading = true;
    notifyListeners();
    try {
      // Fetch law info first to know the user country
      final info = await _service.fetchLawInfo();

      final futures = [
        _service.searchYouTube(query),
        _service.searchNews(query),
        _service.searchGoogle("${query} crypto law", info?.code ?? 'US'),
      ];

      final results = await Future.wait(futures);

      videoResults = results[0] as List<Item>;
      newsResults = results[1] as List<NewsArticle>;
      googleResults = results[2] as List<GoogleResult>;
      lawInfo = info;
      lawLoading = false;
    } catch (e) {
      debugPrint('Search error: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
