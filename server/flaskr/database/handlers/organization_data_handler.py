import os
from psycopg import sql
from flask import current_app

from ..postgres import read_query, write_query, get_db_access
from flaskr.utils.organization import generate_org_slug
from flaskr.models.data.invitation import Invitation

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

                query = f"INSERT INTO organizations (slug, name) values (%s, %s) RETURNING id;"
                params = (orgSlug, orgName)
                cur.execute(query, params)
                orgId = cur.fetchone()[0]

                cur.execute(
                    sql.SQL("CREATE SCHEMA IF NOT EXISTS {};").format(
                        sql.Identifier(str(orgId))
                    )
                )
                cur.execute(
                    sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(orgId)))
                )

                with current_app.open_resource(
                    os.path.join("database", "sql", f"schema.sql")
                ) as f:
                    cur.execute(f.read().decode("utf8"))

                return orgId
        except Exception as e:
            # TODO: Logging
            pass
        return None
    
    @classmethod
    def get_org(cls, id: int):
        query = f"SELECT * from public.organizations WHERE id = %s LIMIT 1;"
        orgs = read_query(query, (id,))
        return orgs[0] if orgs else None

    @classmethod
    def get_existing_slugs(cls):
        query = "SELECT slug from public.organizations;"
        return [res[0] for res in read_query(query)]
    
    @classmethod
    def get_user_org_id(cls, userId):
        query = "SELECT orgId FROM public.memberships WHERE userId = %s LIMIT 1;"
        params = (userId,)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            result = cur.fetchone()
        return result[0] if result else None
    
    @classmethod
    def get_invites(cls, orgId):
        query = "SELECT orgId, email, roleId from public.invitations WHERE orgId = %s;"
        params = (orgId,)
        results = read_query(query, params)
        return [Invitation(*result) for result in results]

    @classmethod
    def revoke_invite(cls, orgId, email):
        query = "DELETE FROM public.invitations WHERE orgId = %s and email = %s;"
        params = (orgId, email)
        write_query(query, params)

    @classmethod
    def add_invite(cls, orgId, email, roleId = None):
        query = "INSERT INTO public.invitations (orgId, email, roleId) VALUES (%s, %s, %s);"
        params = (orgId, email, roleId or 1)
        write_query(query, params)
    
    @classmethod
    def delete_email_invite(cls, email):
        query = "DELETE FROM public.invitations WHERE email = %s;"
        params = (email,)
        write_query(query, params)

    @classmethod
    def check_invite(cls, email):
        # TODO: Handle multiple invitations
        query = "SELECT orgId, roleId from public.invitations WHERE email = %s LIMIT 1;"
        params = (email,)
        result = read_query(query, params)
        return result[0][0] if result else None, None