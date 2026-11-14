class SavedReportConfig {
  final int id;
  final String name;
  final Set<int> columns;
  final Map<String, dynamic> filters;
  final bool showReviews;

  const SavedReportConfig({
    required this.id,
    required this.name,
    required this.columns,
    required this.filters,
    required this.showReviews,
  });

  factory SavedReportConfig.fromJson(Map<String, dynamic> json) {
    final rawFilters = json['filters'] as Map;
    return SavedReportConfig(
      id: json['id'] as int,
      name: json['name'] as String,
      columns: (json['columns'] as List<dynamic>).whereType<int>().toSet(),
      filters: Map<String, dynamic>.from(rawFilters),
      showReviews: json['showReviews'] as bool,
    );
  }
}
