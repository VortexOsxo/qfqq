from dataclasses import dataclass

from .data.decision import Decision

@dataclass(slots=True)
class DecisionReportLine(Decision):
    responsibleName: str

