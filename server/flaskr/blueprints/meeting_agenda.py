from flask import Blueprint, request, jsonify
from flaskr.models import MeetingAgendaStatus
from flaskr.database.mongo.handlers.meeting_agenda_data_handler import MeetingAgendaDataHandler
from datetime import datetime

meeting_agendas_bp = Blueprint('meeting_agendas', __name__, url_prefix='/meeting-agendas')

@meeting_agendas_bp.route('/', methods=['POST'])
def create_meeting_agenda():
    data = request.get_json()
    required_fields = [
        'title', 'reunionGoals', 'status', 'redactionDate', 'meetingDate',
        'meetingLocation', 'animatorId', 'participantsIds', 'themes', 'project'
    ]
    missing = [field for field in required_fields if field not in data]
    if missing:
        return jsonify({'error': f'Missing fields: {", ".join(missing)}'}), 400

    try:
        status = MeetingAgendaStatus[data['status']]
        redactionDate = datetime.fromisoformat(data['redactionDate'])
        meetingDate = datetime.fromisoformat(data['meetingDate'])
        participantsIds = list(map(str, data['participantsIds']))
        themes = list(map(str, data['themes']))
    except Exception as e:
        return jsonify({'error': f'Invalid data format: {str(e)}'}), 400

    MeetingAgendaDataHandler.create_meeting_agenda(
        title=data['title'],
        reunionGoals=data['reunionGoals'],
        status=status,
        redactionDate=redactionDate,
        meetingDate=meetingDate,
        meetingLocation=data['meetingLocation'],
        animatorId=data['animatorId'],
        participantsIds=participantsIds,
        themes=themes,
        project=data['project']
    )
    return jsonify({'message': 'Meeting agenda created successfully'}), 201 