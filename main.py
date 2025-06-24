import sys
import os
import argparse

# Ensure the src directory is in the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '.')))

from src.postgres.config import LOCAL_DB, STAGE_DB
from src.postgres.list_tables import list_stage_tables
from src.postgres.list_local import list_local_tables
from src.postgres.migrate_data import migrate_data
from src.postgres.schema_dumper import run_pg_dump

def main():
    parser = argparse.ArgumentParser(description="PostgreSQL Utility Script")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Sub-parser for listing tables
    parser_list = subparsers.add_parser("list-tables", help="List tables from a specified database")
    parser_list.add_argument(
        "db_type",
        choices=['local', 'stage'],
        help="Specify the database to list tables from ('local' or 'stage')"
    )

    # Sub-parser for generating schema
    parser_schema = subparsers.add_parser("generate-schema", help="Generate schema markdown for a database")
    parser_schema.add_argument(
        "db_type",
        choices=['local', 'stage'],
        help="Specify the database to generate schema for ('local' or 'stage')"
    )
    parser_schema.add_argument(
        "--output",
        default="postgres_schema_details.md",
        help="Output markdown file name (default: postgres_schema_details.md)."
    )

    # Sub-parser for migrating data
    parser_migrate = subparsers.add_parser("migrate-data", help="Migrate data from local to stage database")
    parser_migrate.add_argument(
        "--confirm",
        action="store_true",
        help="Confirm data migration (required to proceed)"
    )

    args = parser.parse_args()

    if args.command == "list-tables":
        if args.db_type == 'local':
            print("Listing tables from LOCAL database (information_schema)...")
            list_local_tables()
        elif args.db_type == 'stage':
            print("Listing tables from STAGE database...")
            list_stage_tables()
    elif args.command == "generate-schema":
        selected_db_config = None
        if args.db_type == 'local':
            print(f"Generating full schema dump for LOCAL database, output to {args.output}...")
            selected_db_config = LOCAL_DB
        elif args.db_type == 'stage':
            print(f"Generating full schema dump for STAGE database, output to {args.output}...")
            print("Ensure SSH tunnel is active if STAGE_DB_HOST in .env is 'localhost' for the stage database.")
            selected_db_config = STAGE_DB
        
        if selected_db_config:
            run_pg_dump(selected_db_config, args.output)
        else:
            # This case should ideally not be reached due to argparse choices
            print("Invalid db_type specified for schema generation.")
    elif args.command == "migrate-data":
        if args.confirm:
            print("Starting data migration from LOCAL to STAGE database...")
            print("Ensure SSH tunnel is active if STAGE_DB_HOST in .env is 'localhost' for the stage database.")
            # Add a final confirmation here if desired
            user_confirmation = input("Are you sure you want to migrate data? This will TRUNCATE tables in STAGE. (yes/no): ")
            if user_confirmation.lower() == 'yes':
                migrate_data()
                print("Data migration process initiated.")
            else:
                print("Data migration cancelled by user.")
        else:
            print("Data migration requires confirmation. Use the --confirm flag.")
            print("Example: python main.py migrate-data --confirm")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

