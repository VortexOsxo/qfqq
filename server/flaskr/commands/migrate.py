import click
from psycopg import sql
from flask.cli import with_appcontext
from flaskr.database.database import Database


@click.command("migrate-db")
@with_appcontext
def migrate_command():
    print("Migrating database")

    with Database._get_db() as conn:
        cur = conn.cursor()

        cur.execute(
            sql.SQL("SET search_path TO {}").format(sql.Identifier("publid"))
        )
        
        Database.run_sql_file_from_cursor(filename="public_migration", cursor=cur)
        print("\t Ran public migration")

        cur.execute("""
            SELECT nspname
            FROM pg_catalog.pg_namespace
            WHERE nspname NOT LIKE 'pg_%'
              AND nspname <> 'information_schema'
            ORDER BY nspname;
        """)

        schemas = cur.fetchall()

        for (schema_name,) in schemas:
            if schema_name == "public":
                continue
            print(f"\tMigrating schema: {schema_name}")
            cur.execute(
                sql.SQL("SET search_path TO {}").format(sql.Identifier(schema_name))
            )

            Database.run_sql_file_from_cursor(filename="migration", cursor=cur)
