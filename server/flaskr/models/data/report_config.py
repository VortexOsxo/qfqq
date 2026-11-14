from dataclasses import dataclass
from typing import Literal, TypeAlias


ProjectStatus: TypeAlias = Literal["inProgress", "completed"]


@dataclass(slots=True)
class ReportConfig:
    id: int
    name: str
    columns: set[int]
    filters: dict
    showReviews: bool

    def to_dict(self) -> dict[str, object]:
        return {
            "id": self.id,
            "name": self.name,
            "columns": sorted(self.columns),
            "filters": self.filters,
            "showReviews": self.showReviews,
        }
