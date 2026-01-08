import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';

class DecisionsFercherService
    extends BaseFetcherService<List<Decision>> {
  final DecisionsService _decisionsService;
  final AuthService _authService;

  DecisionsFercherService(
    this._decisionsService,
    this._authService,
  ) : super() {
    _authService.connectionNotifier.subscribe((_) => loadData());
  }

  @override
  Future<void> loadData() async {
    final decisions = await _decisionsService.loadDecisions();
    state = state.copyWith(data: decisions, isLoaded: true, errorCode: 0);
  }
}
