import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetcherState<T> {
  final T? data;
  final int errorCode;
  final bool isLoaded;

  FetcherState({this.data, this.errorCode = 0, this.isLoaded = false});

  FetcherState<T> copyWith({T? data, int? errorCode, bool? isLoaded}) {
    return FetcherState<T>(
      data: data ?? this.data,
      errorCode: errorCode ?? this.errorCode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

abstract class BaseFetcherService<T> extends StateNotifier<FetcherState<T>> {
  BaseFetcherService() : super(FetcherState<T>());

  bool get isLoaded => state.isLoaded;
  int get errorCode => state.errorCode;

  Future<void> loadData();

  Future<void> loadDataIfNeeded() async {
    if (!state.isLoaded) {
      await loadData();
    }
  }

  void clearData() {
    state = FetcherState<T>(isLoaded: false, errorCode: 0);
  }
}
