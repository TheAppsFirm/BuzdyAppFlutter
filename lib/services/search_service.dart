import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' show placemarkFromCoordinates;
import '../presentation/screens/search/models/google_result.dart';
import '../presentation/screens/search/models/news_article.dart';
import '../presentation/screens/search/models/law_info.dart';
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

  Future<LawInfo?> fetchLawInfo() async {
    String code = 'US';
    try {
      final loc.Location location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
      var permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
      if (permission == loc.PermissionStatus.granted ||
          permission == loc.PermissionStatus.grantedLimited) {
        final data = await location.getLocation();
        if (data.latitude != null && data.longitude != null) {
          final marks = await placemarkFromCoordinates(
            data.latitude!,
            data.longitude!,
          );
          if (marks.isNotEmpty) {
            code = marks.first.isoCountryCode ?? code;
          }
        }
      }
    } catch (_) {}

    if (code == 'US') {
      try {
        final geoRes = await http.get(Uri.parse('https://ipapi.co/json/'));
        if (geoRes.statusCode == 200) {
          final geo = jsonDecode(geoRes.body);
          code = geo['country_code'] ?? 'US';
        }
      } catch (_) {}
    }

    return _lawData[code] ?? _lawData['US'];
  }

  static final Map<String, LawInfo> _lawData = {
    'US': LawInfo(
      country: 'United States',
      legalStatus: 'Legal',
      taxation: 'Capital gains tax applies',
      restrictions: 'No federal restrictions',
      link: 'https://www.usa.gov/cryptocurrency',
    ),
    'IN': LawInfo(
      country: 'India',
      legalStatus: 'Legal with regulation',
      taxation: '30% tax on gains',
      restrictions: 'Regulated exchanges only',
      link:
          'https://en.wikipedia.org/wiki/Regulation_of_cryptocurrency_in_India',
    ),
    'GB': LawInfo(
      country: 'United Kingdom',
      legalStatus: 'Legal',
      taxation: 'Capital gains tax',
      restrictions: 'KYC/AML required',
      link: 'https://www.gov.uk/government',
    ),
  };
}
