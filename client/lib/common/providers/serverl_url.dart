import 'package:flutter_riverpod/flutter_riverpod.dart';

const String localApiUrl = 'http://localhost:5000';
const String deployedApiUrl = 'https://qfqq.fr';

final serverUrlProvider = Provider<String>((ref) {
  return localApiUrl;
});