import subprocess
import os
import argparse
import shlex
from src.mysql.config import MYSQL_DB

def run_mysqldump(db_config, output_filename="mysql_schema_details.md"):
    """
    Generates a full schema dump for the specified database using mysqldump
    and saves it to a markdown file.
    """
    db_name = db_config.get('database', 'unknown_db')
    host = db_config.get('host')
    port = str(db_config.get('port'))
    user = db_config.get('user')
    password = db_config.get('password')

    print(f"Attempting to generate full schema dump for database '{db_name}' using mysqldump...")
    print(f"Output will be saved to: {output_filename}")

    env = os.environ.copy()
    if password:
        env['MYSQL_PWD'] = password

    command = [
        'mysqldump',
        '--host', host,
        '--port', port,
        '--user', user,
        '--no-data',  # Dumps only the schema, not data
        '--databases', db_name
    ]

    try:
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True, # Will raise CalledProcessError for non-zero exit codes
            env=env
        )
        
        with open(output_filename, 'w') as f:
            f.write(f"# Full Schema Dump for Database: {db_name}\n\n")
            f.write("This schema was automatically generated using `mysqldump`.\n\n")
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
        print(f"Error running mysqldump for database '{db_name}':")
        print(f"Command: {' '.join(map(shlex.quote, command))}")
        print(f"Return code: {e.returncode}")
        print(f"Stderr: {e.stderr}")
        return False
    except FileNotFoundError:
        print("Error: 'mysqldump' command not found.")
        print("Please ensure MySQL client tools are installed and 'mysqldump' is in your system's PATH.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred while generating schema for '{db_name}': {e}")
        return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate a full schema dump for a MySQL database using mysqldump.")
    parser.add_argument(
        "--output",
        default="mysql_schema_details.md",
        help="Output markdown file name (default: mysql_schema_details.md)."
    )
    args = parser.parse_args()

    run_mysqldump(MYSQL_DB, args.output)