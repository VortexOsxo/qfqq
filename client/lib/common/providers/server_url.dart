import 'package:flutter_riverpod/flutter_riverpod.dart';

const String localApiUrl = 'http://localhost:5000';
const String deployedApiUrl = 'http://34.42.126.136:5000';

final serverUrlProvider = Provider<String>((ref) {
  return localApiUrl;
});