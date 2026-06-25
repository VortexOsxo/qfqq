from dataclasses import dataclass

@dataclass(slots=True)
class MeetingReview:
    meetingId: int
    userId: int

    isAnonymous: bool
    objective: int
    smoothRunning: int
    preparation: int
    length: int
    respect: int

    comments: str

    def to_dict(self):
        return {
            'meetingId': self.meetingId,
            'userId': self.userId,

            'isAnonymous': self.isAnonymous,
            'objective': self.objective,
            'smoothRunning': self.smoothRunning,
            'preparation': self.preparation,
            'length': self.length,
            'respect': self.respect,

            'comments': self.comments,
        }
