import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' show placemarkFromCoordinates;
import 'package:flutter/foundation.dart';
import '../presentation/screens/search/models/google_result.dart';
import '../presentation/screens/search/models/news_article.dart';
import '../presentation/screens/search/models/law_info.dart';
import '../presentation/screens/dashboard/feed/model/youtubeModel.dart';

class SearchService {
  static const String googleApiKey = 'AIzaSyBBRkfGYeThDsGouKNfVemFpvP-IE8K0F4';
  static const String googleCx = '2751e76d1b65c4320';
  // Use the same key that works for other YouTube requests in the app
  static const String youtubeApiKey = 'AIzaSyATK5cfxRwEFXlp73Su6HrExL5_6Z0puYw';
  static const String newsApiKey = 'cc551033b6c74c529c7c33eca6350156';

  Future<List<GoogleResult>> searchGoogle(String query, String country) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$googleApiKey&cx=$googleCx&q=${Uri.encodeQueryComponent(query)}&gl=$country');
    debugPrint('Google request: $uri');
    final res = await http.get(uri);
    debugPrint('Google response: ${res.statusCode}');
    if (res.statusCode == 200) {
      debugPrint(res.body);
      final data = jsonDecode(res.body);
      final items = data['items'] as List<dynamic>?;
      return items?.map((e) => GoogleResult.fromJson(e)).toList() ?? [];
    }
    debugPrint('Google search failed: ${res.body}');
    return [];
  }

  Future<List<Item>> searchYouTube(String query) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=25&q=${Uri.encodeQueryComponent(query)}&key=$youtubeApiKey');
    debugPrint('YouTube request: $uri');
    final res = await http.get(uri);
    debugPrint('YouTube response: ${res.statusCode}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      YoutubeModel model = YoutubeModel.fromJson(data);
      return model.items ?? [];
    }

    // Fallback using open Piped API when quota exceeded or blocked
    try {
      final altUrls = [
        'https://piped.video/api/v1/search?q=${Uri.encodeQueryComponent(query)}&filter=videos',
        'https://yewtu.be/api/v1/search?q=${Uri.encodeQueryComponent(query)}&filter=videos',
      ];

      for (final url in altUrls) {
        final alt = await http.get(Uri.parse(url));
        debugPrint('Alt YouTube request: $url -> ${alt.statusCode}');
        if (alt.statusCode == 200 && alt.headers['content-type']?.contains('json') == true) {
          final data = jsonDecode(alt.body) as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>?;
          if (items != null) {
            return items.map<Item>((e) {
              final id = e['id']?.toString() ?? '';
              final title = e['title'] ?? '';
              final channel = e['uploaderName'] ?? '';
              final thumb = e['thumbnail'] ?? '';
              return Item(
                id: id,
                videoId: id,
                snippet: Snippet(
                  title: title,
                  channelTitle: channel,
                  thumbnails: Thumbnails(
                    thumbnailsDefault: ThumbnailData(url: thumb, width: 120, height: 90),
                  ),
                ),
              );
            }).toList();
          }
        }
      }
    } catch (_) {}

    return [];
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    final uri = Uri.parse(
        'https://newsapi.org/v2/everything?apiKey=$newsApiKey&pageSize=50&q=${Uri.encodeQueryComponent(query)}');
    debugPrint('News request: $uri');
    final res = await http.get(uri);
    debugPrint('News response: ${res.statusCode}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final articles = data['articles'] as List<dynamic>?;
      return articles?.map((e) => NewsArticle.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  Future<LawInfo?> fetchLawInfo() async {
    String code = 'US';
    String country = 'United States';

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
            country = marks.first.country ?? country;
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
          country = geo['country_name'] ?? country;
        }
      } catch (_) {}
    }

    final info = _lawData[code];
    if (info != null) {
      return LawInfo(
        code: code,
        country: country,
        legalStatus: info.legalStatus,
        taxation: info.taxation,
        restrictions: info.restrictions,
        link: info.link,
      );
    }

    return LawInfo(
      code: code,
      country: country,
      legalStatus: 'Unknown',
      taxation: 'Unknown',
      restrictions: 'Unknown',
      link: null,
    );
  }

  static final Map<String, LawInfo> _lawData = {
    'US': LawInfo(
      code: 'US',
      country: 'United States',
      legalStatus: 'Legal',
      taxation: 'Capital gains tax applies',
      restrictions: 'No federal restrictions',
      link: 'https://www.usa.gov/cryptocurrency',
    ),
    'IN': LawInfo(
      code: 'IN',
      country: 'India',
      legalStatus: 'Legal with regulation',
      taxation: '30% tax on gains',
      restrictions: 'Regulated exchanges only',
      link:
          'https://en.wikipedia.org/wiki/Regulation_of_cryptocurrency_in_India',
    ),
    'GB': LawInfo(
      code: 'GB',
      country: 'United Kingdom',
      legalStatus: 'Legal',
      taxation: 'Capital gains tax',
      restrictions: 'KYC/AML required',
      link: 'https://www.gov.uk/government',
    ),
  };
}
