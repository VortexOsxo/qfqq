from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    HRFlowable,
    Table,
    TableStyle,
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.pagesizes import A4
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.colors import HexColor, lightgrey
from reportlab.pdfbase.pdfmetrics import stringWidth

from flaskr.models import decision_status_as_string
from .report_columns import (
    MEETING_REPORT_DECISION_COLUMNS,
    PROJECT_REPORT_DECISION_COLUMNS,
    select_report_columns,
)


styles = getSampleStyleSheet()

primary_color = HexColor("#36618E")

title_style_big = ParagraphStyle(
    "TitleStyleBig",
    parent=styles["Title"],
    fontSize=32,
    spaceAfter=15,
    alignment=TA_LEFT,
    textColor=primary_color,
    bold=True,
)

title_style_small = ParagraphStyle(
    "TitleStyleSmall",
    parent=title_style_big,
    fontSize=14,
    spaceAfter=2,
)

body_style = ParagraphStyle(
    "BodyStyle", parent=styles["Normal"], fontSize=11, leading=15
)

row_table_style = TableStyle(
    [
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 0),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
    ]
)

table_header_style = ParagraphStyle(
    "TableHeaderStyle",
    parent=styles["Normal"],
    fontSize=11,
    spaceAfter=0,
    textColor=primary_color,
    fontName="Helvetica-Bold",
)

content_table_style = TableStyle(
    [("VALIGN", (0, 0), (-1, -1), "TOP"),],
    parent=row_table_style,
)


background_table_style = TableStyle(
    [
        ("BACKGROUND", (0, 0), (-1, -1), lightgrey),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
)

class ReportBuilder:
    def __init__(self, accent_color=primary_color):
        self.doc = None
        self.elements = []
        self.accent_color = accent_color

    def _accent_style(self, style):
        return ParagraphStyle(
            f"{style.name}Accent",
            parent=style,
            textColor=self.accent_color,
        )

    def start(self, buffer, margin: int = 28):
        self.doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            rightMargin=margin,
            leftMargin=margin,
            topMargin=margin,
            bottomMargin=margin,
        )
        return self

    def add_element(self, element):
        self.elements.append(element)
        return self

    def header(self, title: str, subtitle: str = None, date: str = None):
        title_style = self._accent_style(title_style_big)
        small_title_style = self._accent_style(title_style_small)
        title = Paragraph(title, title_style)
        date_text = Paragraph(
            f"Date: {date}",
            ParagraphStyle(
                "DateStyle",
                parent=small_title_style,
                alignment=TA_RIGHT,
            ),
        )

        if subtitle is not None:
            self.elements.append(title)

            subtitle = Paragraph(subtitle, small_title_style)
            if date is None:
                self.elements.append(subtitle)
            else:
                title_row = Table([[subtitle, date_text]], colWidths=["50%", "50%"])
                title_row.setStyle(row_table_style)
                self.elements.append(title_row)

        elif date is not None:
            title_row = Table([[title, date_text]], colWidths=["50%", "50%"])
            title_row.setStyle(row_table_style)
            self.elements.append(title_row)

        else:
            self.elements.append(title)
        return self

    def division(self, thickness: int = 5):
        self.elements.append(
            HRFlowable(width="100%", thickness=thickness, color=self.accent_color)
        )
        return self

    def spacer(self, height: int = 12):
        self.elements.append(Spacer(1, height))
        return self

    def table_header(self, headers: list[str], col_widths: list[str] = None):
        header_style = self._accent_style(table_header_style)
        headers = [Paragraph(text, header_style) for text in headers]
        project_table = Table([headers], colWidths=col_widths)
        project_table.setStyle(content_table_style)
        self.elements.append(project_table)

        self.division(thickness=2)
        return self

    def table_section(self, text: str):
        paragraph = Paragraph(text, self._accent_style(table_header_style))
        table = Table([[paragraph]], colWidths=["100%"])
        table.setStyle(background_table_style)
        self.elements.append(table)
        return self

    def table_content(self, data: list[list[str]], col_widths: list[str] = None):
        for row in data:
            row = [Paragraph(str(cell), body_style) for cell in row]
            table = Table([row], colWidths=col_widths)
            table.setStyle(content_table_style)
            self.elements.append(table)
        return self

    def text_column(self, label, values):
        header_style = self._accent_style(table_header_style)
        label_paragraph = Paragraph(label, header_style)
        value_paragraphs = [Paragraph(str(value), body_style) for value in values]
        data = [[label_paragraph]] + [[vp] for vp in value_paragraphs]
        table = Table(data, colWidths=["100%"])
        table.setStyle(content_table_style)
        return table

    def text_row(self, label, values):
        header_style = self._accent_style(table_header_style)
        label_paragraph = Paragraph(f"{label}: ", header_style)
        label_width = stringWidth(f"{label}: ", header_style.fontName, header_style.fontSize)

        value_paragraphs = Paragraph(", ".join(values), body_style)

        data = [[label_paragraph] + [value_paragraphs]]

        table = Table(data, [label_width+3, "100%"])
        table.setStyle(content_table_style)
        return table

    def decisions_table(self, decisions, lang, selected_columns=None):
        cols = MEETING_REPORT_DECISION_COLUMNS
        headers = (
            ["N", "Action", "Responsable", "Échéance", "Statut", "Date de fin"]
            if lang == "fr"
            else ["N", "Action", "Responsible", "Due Date", "Status", "Completed Date"]
        )
        values = [
            [
                str(decision.number+1000),
                decision.description,
                decision.responsibleName,
                decision.dueDate.strftime("%Y-%m-%d") if decision.dueDate else " ",
                decision_status_as_string(decision.status, lang),
                (
                    decision.completedDate.strftime("%Y-%m-%d")
                    if decision.completedDate
                    else " "
                ),
            ]
            for decision in decisions
        ]
        headers, values, cols = select_report_columns(
            [
                "number",
                "description",
                "responsible",
                "dueDate",
                "status",
                "completedDate",
            ],
            headers,
            values,
            cols,
            selected_columns,
            {"description"},
        )
        if not headers:
            return

        self.table_header(headers, cols)
        self.table_content(values, cols)

    def decisions_table_with_meeting_id(
        self, decisions, lang, selected_columns=None
    ):
        cols = PROJECT_REPORT_DECISION_COLUMNS
        headers = (
            ["N", "R", "Action", "Responsable", "Échéance", "Statut", "Date de fin"]
            if lang == "fr"
            else ["N", "M", "Action", "Responsible", "Due Date", "Status", "Completed Date"]
        )
        values = [
            [
                str(decision.number),
                str(decision.meetingId),
                decision.description,
                decision.responsibleName,
                decision.dueDate.strftime("%Y-%m-%d") if decision.dueDate else " ",
                decision_status_as_string(decision.status, lang),
                (
                    decision.completedDate.strftime("%Y-%m-%d")
                    if decision.completedDate
                    else " "
                ),
            ]
            for decision in decisions
        ]
        headers, values, cols = select_report_columns(
            [
                "number",
                "meetingId",
                "description",
                "responsible",
                "dueDate",
                "status",
                "completedDate",
            ],
            headers,
            values,
            cols,
            selected_columns,
            {"description"},
        )
        if not headers:
            return

        self.table_header(headers, cols)
        self.table_content(values, cols)

    def build(self, reset=True):
        self.doc.build(self.elements)
        if reset:
            self.elements = []
            self.doc = None
        return self
