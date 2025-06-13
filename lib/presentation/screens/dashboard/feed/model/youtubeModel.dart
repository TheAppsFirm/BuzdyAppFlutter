import 'dart:convert';

YoutubeModel youtubeModelFromJson(String str) =>
    YoutubeModel.fromJson(json.decode(str));

String youtubeModelToJson(YoutubeModel data) => json.encode(data.toJson());

class YoutubeModel {
  final String? kind;
  final String? etag;
  final String? nextPageToken;
  final PageInfo? pageInfo;
  final List<Item>? items;

  YoutubeModel({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.pageInfo,
    this.items,
  });

  factory YoutubeModel.fromJson(Map<String, dynamic> json) => YoutubeModel(
        kind: json["kind"] ?? "",
        etag: json["etag"] ?? "",
        nextPageToken: json["nextPageToken"] ?? "",
        pageInfo: json["pageInfo"] != null
            ? PageInfo.fromJson(json["pageInfo"])
            : null,
        items: json["items"] != null
            ? List<Item>.from(json["items"].map((x) => Item.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "nextPageToken": nextPageToken,
        "pageInfo": pageInfo?.toJson(),
        "items": items != null
            ? List<dynamic>.from(items!.map((x) => x.toJson()))
            : [],
      };
}

class Item {
  final String? kind;
  final String? etag;
  final String? id;
  final String? videoId;
  final Snippet? snippet;

  Item({
    this.kind,
    this.etag,
    this.id,
    this.videoId,
    this.snippet,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        kind: json["kind"] ?? "",
        etag: json["etag"] ?? "",
        id: json["id"] is String
            ? json["id"]
            : json["id"]?["playlistId"] ?? json["id"]?["videoId"] ?? "",
        videoId: json["id"] is Map ? json["id"]?["videoId"] : json["id"],
        snippet:
            json["snippet"] != null ? Snippet.fromJson(json["snippet"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "id": id,
        "videoId": videoId,
        "snippet": snippet?.toJson(),
      };
}

class Snippet {
  final DateTime? publishedAt;
  final String? channelId;
  final String? title;
  final String? description;
  final Thumbnails? thumbnails;
  final String? channelTitle;
  final Localized? localized;

  Snippet({
    this.publishedAt,
    this.channelId,
    this.title,
    this.description,
    this.thumbnails,
    this.channelTitle,
    this.localized,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        publishedAt: json["publishedAt"] != null
            ? DateTime.parse(json["publishedAt"])
            : null,
        channelId: json["channelId"] ?? "",
        title: json["title"] ?? "Unknown Title",
        description: json["description"] ?? "",
        thumbnails: json["thumbnails"] != null
            ? Thumbnails.fromJson(json["thumbnails"])
            : null,
        channelTitle: json["channelTitle"] ?? "Unknown Channel",
        localized: json["localized"] != null
            ? Localized.fromJson(json["localized"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "publishedAt": publishedAt?.toIso8601String(),
        "channelId": channelId,
        "title": title,
        "description": description,
        "thumbnails": thumbnails?.toJson(),
        "channelTitle": channelTitle,
        "localized": localized?.toJson(),
      };
}

class Localized {
  final String? title;
  final String? description;

  Localized({
    this.title,
    this.description,
  });

  factory Localized.fromJson(Map<String, dynamic> json) => Localized(
        title: json["title"] ?? "Unknown",
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}

class Thumbnails {
  final ThumbnailData? thumbnailsDefault;
  final ThumbnailData? medium;
  final ThumbnailData? high;
  final ThumbnailData? standard;
  final ThumbnailData? maxres;

  Thumbnails({
    this.thumbnailsDefault,
    this.medium,
    this.high,
    this.standard,
    this.maxres,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) => Thumbnails(
        thumbnailsDefault: json["default"] != null
            ? ThumbnailData.fromJson(json["default"])
            : null,
        medium: json["medium"] != null
            ? ThumbnailData.fromJson(json["medium"])
            : null,
        high:
            json["high"] != null ? ThumbnailData.fromJson(json["high"]) : null,
        standard: json["standard"] != null
            ? ThumbnailData.fromJson(json["standard"])
            : null,
        maxres: json["maxres"] != null
            ? ThumbnailData.fromJson(json["maxres"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "default": thumbnailsDefault?.toJson(),
        "medium": medium?.toJson(),
        "high": high?.toJson(),
        "standard": standard?.toJson(),
        "maxres": maxres?.toJson(),
      };
}

class ThumbnailData {
  final String? url;
  final int? width;
  final int? height;

  ThumbnailData({
    this.url,
    this.width,
    this.height,
  });

  factory ThumbnailData.fromJson(Map<String, dynamic> json) => ThumbnailData(
        url: json["url"] ?? "",
        width: json["width"] != null ? json["width"] as int : 0,
        height: json["height"] != null ? json["height"] as int : 0,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
      };
}

class PageInfo {
  final int? totalResults;
  final int? resultsPerPage;

  PageInfo({
    this.totalResults,
    this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults:
            json["totalResults"] != null ? json["totalResults"] as int : 0,
        resultsPerPage:
            json["resultsPerPage"] != null ? json["resultsPerPage"] as int : 0,
      );

  Map<String, dynamic> toJson() => {
        "totalResults": totalResults,
        "resultsPerPage": resultsPerPage,
      };
}
