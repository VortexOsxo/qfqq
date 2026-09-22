class HelpInfo {
  final String title;
  final String description;

  const HelpInfo({required this.title, required this.description});
}

class HelpContent {
  final String title;
  final String tooltip;
  final List<HelpInfo> tips;

  const HelpContent({
    required this.title,
    required this.tooltip,
    required this.tips,
  });
}
