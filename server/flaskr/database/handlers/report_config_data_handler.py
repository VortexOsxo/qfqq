import ast

from ..postgres import read_query, get_db_access
from flaskr.models import ReportConfig


class ReportConfigDataHandler:
    @classmethod
    def create_report_config(cls, name, columns, filters, showReviews = False):
        encodedColumns = str(columns)
        encodedFilters = str(filters)

        with get_db_access() as conn:
            cur = conn.cursor()
            query = f"INSERT INTO reportsConfigs (name, encodedColumns, encodedFilters, showReviews) values (%s, %s, %s, %s) RETURNING id;"
            params = (name, encodedColumns, encodedFilters, showReviews)
            cur.execute(query, params)
            id = cur.fetchone()[0]
        return ReportConfig(id, name, columns, filters, showReviews)

    @classmethod
    def get_report_configs(cls):
        query = "SELECT id, name, encodedColumns, encodedFilters, showReviews FROM reportsConfigs;"
        configs= []
        for item in read_query(query):
            id, name, encodedColumns, encodedFilters, showReviews = item
            columns = ast.literal_eval(encodedColumns)
            filters = ast.literal_eval(encodedFilters)
            configs.append(ReportConfig(id, name, columns, filters, showReviews))
        return configs

    @classmethod
    def delete_report_config(cls, id):
        query = "DELETE FROM reportsConfigs WHERE id = %s;"
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, (id,))