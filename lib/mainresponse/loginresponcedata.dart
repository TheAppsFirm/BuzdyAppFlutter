class Responses {
  int? status;
  String? message;
  dynamic data;
  Map<String, dynamic>? pagination; // New field for pagination

  Responses({
    required this.status,
    this.message,
    required this.data,
    this.pagination, // Optional
  });

  factory Responses.fromJson(Map<String, dynamic> json) {
    // Possible keys where "data" might be found
    List<String> possibleDataKeys = [
      'user',
      'data',
      'blog',
      'deal',
      'banks',
      'atm',
    ];

    // Find the first existing key in the JSON
    String? dataKey = possibleDataKeys.firstWhere(
      (key) => json.containsKey(key),
      orElse: () => 'key_not_found',
    );

    return Responses(
      status: json['status'],
      message: json['message'],
      data: dataKey != 'key_not_found' ? json[dataKey] : json,
      pagination: json.containsKey('pagination')
          ? json['pagination']
          : null, // Handle pagination
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      if (pagination != null)
        'pagination': pagination, // Only include if not null
    };
  }
}
