class LawInfo {
  final String code;
  final String country;
  final String legalStatus;
  final String taxation;
  final String restrictions;
  final String? link;

  LawInfo({
    required this.code,
    required this.country,
    required this.legalStatus,
    required this.taxation,
    required this.restrictions,
    this.link,
  });
}
