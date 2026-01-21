import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';

class UserMeetingsFetcherService
    extends BaseFetcherService<List<MeetingAgenda>> {
  final MeetingAgendaService _agendasService;
  final AuthService _authService;

  UserMeetingsFetcherService(
    this._agendasService,
    this._authService,
  ) : super() {
    _authService.connectionNotifier.subscribe((_) => loadData());
  }

  @override
  Future<void> loadData() async {
    final agendas = await _agendasService.getMeetingAgendas('participantId=me');
    state = state.copyWith(data: agendas, isLoaded: true, errorCode: 0);
  }
}
