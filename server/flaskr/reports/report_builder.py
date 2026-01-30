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
from reportlab.lib.colors import Color, lightgrey
from reportlab.pdfbase.pdfmetrics import stringWidth

decisions = [
    {
        "N": 1,
        "Action": "Improve documentation, becaues right now it's lacking",
        "Responsable": "Alice",
        "Echeance": "2024-07-01",
        "Statut": "In Progress",
        "Fin": "",
    },
    {
        "N": 2,
        "Action": "Refactor codebase",
        "Responsable": "Bob",
        "Echeance": "2024-08-15",
        "Statut": "Not Started",
        "Fin": "",
    },
    {
        "N": 3,
        "Action": "Update dependencies",
        "Responsable": "Charlie",
        "Echeance": "2024-06-30",
        "Statut": "Completed",
        "Fin": "2024-06-25",
    },
]

styles = getSampleStyleSheet()

dark_grey_color = Color(0.325, 0.325, 0.400)

title_style_big = ParagraphStyle(
    "TitleStyleBig",
    parent=styles["Title"],
    fontSize=32,
    spaceAfter=15,
    alignment=TA_LEFT,
    textColor=dark_grey_color,
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
    textColor=dark_grey_color,
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
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]
)


class ReportBuilder:
    def __init__(self):
        self.doc = None
        self.elements = []

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

    def header(self, title: str, subtitle: str = None, date: str = None):
        title = Paragraph(title, title_style_big)
        date = Paragraph(
            f"Date: {date}",
            ParagraphStyle(
                "DateStyle",
                parent=title_style_small,
                alignment=TA_RIGHT,
            ),
        )

        if subtitle is not None:
            self.elements.append(title)

            subtitle = Paragraph(subtitle, title_style_small)
            if date is None:
                self.elements.append(subtitle)
            else:
                title_row = Table([[subtitle, date]], colWidths=["50%", "50%"])
                title_row.setStyle(row_table_style)
                self.elements.append(title_row)

        elif date is not None:
            title_row = Table([[title, date]], colWidths=["50%", "50%"])
            title_row.setStyle(row_table_style)
            self.elements.append(title_row)

        else:
            self.elements.append(title)
        return self

    def division(self, thickness: int = 5):
        self.elements.append(
            HRFlowable(width="100%", thickness=thickness, color=dark_grey_color)
        )
        return self

    def spacer(self, height: int = 12):
        self.elements.append(Spacer(1, height))
        return self

    def table_header(self, headers: list[str], col_widths: list[str] = None):
        headers = [Paragraph(text, table_header_style) for text in headers]
        project_table = Table([headers], colWidths=col_widths)
        project_table.setStyle(content_table_style)
        self.elements.append(project_table)

        self.division(thickness=2)
        return self

    def table_section(self, text: str):
        paragraph = Paragraph(text, table_header_style)
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

    def column(self, label, values):
        label_paragraph = Paragraph(label, table_header_style)
        value_paragraphs = [Paragraph(str(value), body_style) for value in values]
        data = [[label_paragraph]] + [[vp] for vp in value_paragraphs]
        table = Table(data, colWidths=["100%"])
        table.setStyle(content_table_style)
        self.elements.append(table)
        return self

    def row(self, label, values):
        label_paragraph = Paragraph(f"{label}: ", table_header_style)
        label_width = stringWidth(f"{label}: ", table_header_style.fontName, table_header_style.fontSize)

        value_paragraphs = Paragraph(", ".join(values), body_style)
        
        data = [[label_paragraph] + [value_paragraphs]]
        
        table = Table(data, [label_width+3, "100%"])
        table.setStyle(content_table_style)
        
        self.elements.append(table)
        return self

    def build(self, reset=True):
        self.doc.build(self.elements)
        if reset:
            self.elements = []
            self.doc = None
        return self
