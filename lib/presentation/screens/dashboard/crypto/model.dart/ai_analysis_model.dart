import 'dart:convert';

AiAnalysisModel aiAnalysisModelFromJson(String str) => AiAnalysisModel.fromJson(json.decode(str));

class AiAnalysisModel {
  final Map<String, dynamic> analysis;

  AiAnalysisModel({required this.analysis});

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) =>
      AiAnalysisModel(analysis: json['analysis'] ?? {});

  Map<String, dynamic> toJson() => {'analysis': analysis};
}
