import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionTokenStoreProvider = Provider<SessionTokenStore>(
  (_) => SessionTokenStore(),
);

class SessionTokenStore {
  String? token;
}
