import 'dart:convert';
import 'package:http/http.dart' as http;
import '../presentation/screens/search/models/google_result.dart';
import '../presentation/screens/search/models/news_article.dart';
import '../presentation/screens/dashboard/feed/model/youtubeModel.dart';

class SearchService {
  static const String googleApiKey = 'AIzaSyBBRkfGYeThDsGouKNfVemFpvP-IE8K0F4';
  static const String googleCx = '2751e76d1b65c4320';
  static const String youtubeApiKey = 'AIzaSyCAZqxVkmXlTxFIqW1-a0PoTQlZeuTyiI0';
  static const String newsApiKey = 'cc551033b6c74c529c7c33eca6350156';

  Future<List<GoogleResult>> searchGoogle(String query) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$googleApiKey&cx=$googleCx&q=${Uri.encodeQueryComponent(query)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final items = data['items'] as List<dynamic>?;
      return items?.map((e) => GoogleResult.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  Future<List<Item>> searchYouTube(String query) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=${Uri.encodeQueryComponent(query)}&key=$youtubeApiKey');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      YoutubeModel model = YoutubeModel.fromJson(data);
      return model.items ?? [];
    }
    return [];
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    final uri = Uri.parse(
        'https://newsapi.org/v2/everything?apiKey=$newsApiKey&q=${Uri.encodeQueryComponent(query)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final articles = data['articles'] as List<dynamic>?;
      return articles?.map((e) => NewsArticle.fromJson(e)).toList() ?? [];
    }
    return [];
  }
}
