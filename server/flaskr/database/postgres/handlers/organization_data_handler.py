import os
import psycopg
from psycopg import sql
from flask import current_app

from ..postgres import read_query, write_query, get_db_access
from flaskr.utils.organization import generate_org_slug


class OrganizationDataHandler:
    @classmethod
    def create_organization(cls, orgName: str) -> str | None:
        baseSlug = generate_org_slug(orgName)
        orgSlug = baseSlug
        existing_slugs = cls.get_existing_slugs()

        index = 2
        while orgSlug in existing_slugs:
            orgSlug = f"{baseSlug}{index}"
            index += 1

        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = f"INSERT INTO organizations (orgSlug, orgName) values (%s, %s);"
                params = (orgSlug, orgName)
                cur.execute(query, params)

                cur.execute(
                    sql.SQL("CREATE SCHEMA IF NOT EXISTS {};").format(
                        sql.Identifier(orgSlug)
                    )
                )
                cur.execute(
                    sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(orgSlug))
                )

                with current_app.open_resource(
                    os.path.join("database", "postgres", f"schema.sql")
                ) as f:
                    cur.execute(f.read().decode("utf8"))

                return orgSlug
        except Exception as e:
            # TODO: Logging
            pass
        return None
    
    @classmethod
    def get_existing_slugs(cls):
        query = "SELECT orgSlug from organizations;"
        return [res[0] for res in read_query(query)]
    
    @classmethod
    def get_user_org_id(cls, userId):
        query = "SELECT orgId FROM memberships WHERE userId = %s LIMIT 1;"
        params = (userId,)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            result = cur.fetchone()
        return result[0] if result else None