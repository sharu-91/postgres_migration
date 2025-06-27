import sys
import os
import argparse

# Ensure the src directory is in the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '.')))

from src.postgres.config import LOCAL_DB as PG_LOCAL_DB, STAGE_DB as PG_STAGE_DB
from src.mysql.config import MYSQL_DB
from src.postgres.list_tables import list_stage_tables as list_pg_stage_tables
from src.postgres.list_local import list_local_tables as list_pg_local_tables
from src.mysql.list_tables import list_mysql_tables
from src.postgres.migrate_data import migrate_data as migrate_pg_data
from src.mysql.migrate_data import migrate_data as migrate_mysql_data
from src.postgres.schema_dumper import run_pg_dump
from src.mysql.schema_dumper import run_mysqldump

def main():
    parser = argparse.ArgumentParser(description="Database Utility Script")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Sub-parser for listing tables
    parser_list = subparsers.add_parser("list-tables", help="List tables from a specified database")
    parser_list.add_argument(
        "db_type",
        choices=['pg-local', 'pg-stage', 'mysql'],
        help="Specify the database to list tables from ('pg-local', 'pg-stage', or 'mysql')"
    )

    # Sub-parser for generating schema
    parser_schema = subparsers.add_parser("generate-schema", help="Generate schema markdown for a database")
    parser_schema.add_argument(
        "db_type",
        choices=['pg-local', 'pg-stage', 'mysql'],
        help="Specify the database to generate schema for ('pg-local', 'pg-stage', or 'mysql')"
    )
    parser_schema.add_argument(
        "--output",
        help="Output markdown file name."
    )

    # Sub-parser for migrating data
    parser_migrate = subparsers.add_parser("migrate", help="Migrate data from one database to another")
    parser_migrate.add_argument(
        "migration_type",
        choices=['pg-local-to-stage', 'mysql-to-pg-local'],
        help="Specify the migration type"
    )
    parser_migrate.add_argument(
        "--confirm",
        action="store_true",
        help="Confirm data migration (required to proceed)"
    )
    parser_migrate.add_argument(
        '--tables',
        nargs='+',
        help='An optional list of tables to migrate'
    )

    args = parser.parse_args()

    if args.command == "list-tables":
        if args.db_type == 'pg-local':
            print("Listing tables from PostgreSQL LOCAL database (information_schema)...")
            list_pg_local_tables()
        elif args.db_type == 'pg-stage':
            print("Listing tables from PostgreSQL STAGE database...")
            list_pg_stage_tables()
        elif args.db_type == 'mysql':
            print("Listing tables from MySQL database...")
            list_mysql_tables()

    elif args.command == "generate-schema":
        if args.db_type == 'pg-local':
            output = args.output or "postgres_schema_details.md"
            print(f"Generating full schema dump for PostgreSQL LOCAL database, output to {output}...")
            run_pg_dump(PG_LOCAL_DB, output)
        elif args.db_type == 'pg-stage':
            output = args.output or "postgres_schema_details.md"
            print(f"Generating full schema dump for PostgreSQL STAGE database, output to {output}...")
            print("Ensure SSH tunnel is active if STAGE_DB_HOST in .env is 'localhost' for the stage database.")
            run_pg_dump(PG_STAGE_DB, output)
        elif args.db_type == 'mysql':
            output = args.output or "mysql_schema_details.md"
            print(f"Generating full schema dump for MySQL database, output to {output}...")
            run_mysqldump(MYSQL_DB, output)

    elif args.command == "migrate":
        if args.confirm:
            if args.migration_type == 'pg-local-to-stage':
                print("Starting data migration from PostgreSQL LOCAL to STAGE database...")
                print("Ensure SSH tunnel is active if STAGE_DB_HOST in .env is 'localhost' for the stage database.")
                user_confirmation = input("Are you sure you want to migrate data? This will TRUNCATE tables in STAGE. (yes/no): ")
                if user_confirmation.lower() == 'yes':
                    migrate_pg_data()
                    print("Data migration process initiated.")
                else:
                    print("Data migration cancelled by user.")
            elif args.migration_type == 'mysql-to-pg-local':
                print("Starting data migration from MySQL to PostgreSQL LOCAL database...")
                user_confirmation = input("Are you sure you want to migrate data? This will TRUNCATE tables in PostgreSQL LOCAL. (yes/no): ")
                if user_confirmation.lower() == 'yes':
                    migrate_mysql_data(args.tables)
                    print("Data migration process initiated.")
                else:
                    print("Data migration cancelled by user.")
        else:
            print("Data migration requires confirmation. Use the --confirm flag.")
            print("Example: python main.py migrate mysql-to-pg-local --confirm")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

