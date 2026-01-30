import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectViewContentProvider = StateNotifierProvider((ref) => ProjectViewContentService());

class ProjectViewContentService extends StateNotifier<String> {
  ProjectViewContentService(): super('decisions');

  void changeContent(String content) {
    state = content;
  }
}

