import subprocess
import os
import argparse
import shlex
from src.postgres.config import LOCAL_DB, STAGE_DB

def run_pg_dump(db_config, output_filename="postgres_schema_details.md"):
    """
    Generates a full schema dump for the specified database using pg_dump
    and saves it to a markdown file.
    """
    db_name = db_config.get('database', 'unknown_db')
    host = db_config.get('host')
    port = str(db_config.get('port'))
    user = db_config.get('user')
    password = db_config.get('password')

    print(f"Attempting to generate full schema dump for database '{db_name}' using pg_dump...")
    print(f"Output will be saved to: {output_filename}")

    env = os.environ.copy()
    if password:
        env['PGPASSWORD'] = password

    # Base pg_dump command for schema only
    # We will dump the entire public schema.
    # If specific tables were needed, -t table_name could be added.
    command = [
        'pg_dump',
        '--host', host,
        '--port', port,
        '--username', user,
        '--schema-only',  # Dumps only the schema, not data
        '--schema', 'public', # Focus on the public schema, can be adjusted
        '--no-owner',     # Optional: Exclude ALTER OWNER commands
        '--no-privileges',# Optional: Exclude GRANT/REVOKE commands
        db_name
    ]

    try:
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True, # Will raise CalledProcessError for non-zero exit codes
            env=env
        )
        
        # Format the output into a markdown file
        with open(output_filename, 'w') as f:
            f.write(f"# Full Schema Dump for Database: {db_name}\n\n")
            f.write("This schema was automatically generated using `pg_dump`.\n\n")
            f.write("## Connection Information (from .env)\n")
            f.write(f"- **Host:** {db_config.get('host')}\n")
            f.write(f"- **Port:** {db_config.get('port')}\n")
            f.write(f"- **User:** {db_config.get('user')}\n")
            f.write(f"- **Database:** {db_name}\n\n")
            f.write("## Schema Dump\n\n")
            f.write("```sql\n")
            f.write(process.stdout)
            f.write("\n```\n")
        
        print(f"Successfully created full schema dump: {output_filename} for database '{db_name}'")
        return True

    except subprocess.CalledProcessError as e:
        print(f"Error running pg_dump for database '{db_name}':")
        print(f"Command: {' '.join(map(shlex.quote, command))}")
        print(f"Return code: {e.returncode}")
        print(f"Stderr: {e.stderr}")
        if password: # Advise to check password if one was used
            print("Ensure PGPASSWORD was correctly set or consider using a .pgpass file if issues persist.")
        return False
    except FileNotFoundError:
        print("Error: 'pg_dump' command not found.")
        print("Please ensure PostgreSQL client tools are installed and 'pg_dump' is in your system's PATH.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred while generating schema for '{db_name}': {e}")
        return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate a full schema dump for a PostgreSQL database using pg_dump.")
    parser.add_argument(
        "db_type",
        choices=['local', 'stage'],
        help="Specify the database type to generate schema for ('local' or 'stage')."
    )
    parser.add_argument(
        "--output",
        default="postgres_schema_details.md",
        help="Output markdown file name (default: postgres_schema_details.md)."
    )
    args = parser.parse_args()

    selected_db_config = None
    if args.db_type == 'local':
        print("Generating full schema dump for LOCAL database...")
        selected_db_config = LOCAL_DB
    elif args.db_type == 'stage':
        print("Generating full schema dump for STAGE database...")
        print("Ensure SSH tunnel is active if STAGE_DB_HOST in .env is 'localhost' for the stage database.")
        selected_db_config = STAGE_DB
    
    if selected_db_config:
        run_pg_dump(selected_db_config, args.output)
    else:
        print("Invalid db_type specified.")