import psycopg2
import json
import logging
import io

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

from src.postgres.config import LOCAL_DB, STAGE_DB

<<<<<<< HEAD
# Hardcoded list of tables to migrate
TABLES_TO_MIGRATE = [
   
]
=======
def get_tables_to_migrate(file_path="tables.txt"):
    """Reads the list of tables to migrate from a file."""
    with open(file_path, 'r') as f:
        tables = [line.strip() for line in f.readlines()]
    return tables
>>>>>>> 6678a9f (mysql migration script and removed hardcoded table listing in migrate data)

def migrate_data_with_copy(local_cursor, stage_cursor, table):
    logging.info(f"Starting migration for table: {table} using COPY")

    # Truncate the table before migrating
    logging.info(f"Truncating table {table} in staging database.")
    stage_cursor.execute(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE")
    stage_cursor.connection.commit()
    logging.info(f"Table {table} truncated.")

    # Use an in-memory buffer
    buffer = io.StringIO()

    # Fetch data from local table and write to buffer
    local_cursor.copy_expert(f"COPY {table} TO STDOUT WITH CSV", buffer)
    buffer.seek(0) # Rewind the buffer to the beginning

    # Upload to staging table
    stage_cursor.copy_expert(f"COPY {table} FROM STDIN WITH CSV", buffer)
    stage_cursor.connection.commit()

    logging.info(f"Successfully migrated data to {table} using COPY.")

def migrate_data():
    local_conn = None
    stage_conn = None
    local_cursor = None
    stage_cursor = None
    try:
        # Connect to local and staging databases
        logging.info("Connecting to local database...")
        local_conn = psycopg2.connect(**LOCAL_DB)
        local_cursor = local_conn.cursor()
        logging.info("Successfully connected to local database.")

        logging.info("Connecting to staging database...")
        stage_conn = psycopg2.connect(**STAGE_DB)
        stage_cursor = stage_conn.cursor()
        logging.info("Successfully connected to staging database.")

        tables_to_migrate = get_tables_to_migrate()
        for table in tables_to_migrate:
            try:
                migrate_data_with_copy(local_cursor, stage_cursor, table)

            except Exception as e:
                logging.error(f"An error occurred during migration for table {table}: {e}")
                if stage_conn and not stage_conn.closed:
                    stage_conn.rollback()
                logging.info(f"Aborting migration for table {table} and continuing to the next one.")


    except Exception as e:
        logging.error(f"A critical error occurred: {e}")
        if stage_conn and not stage_conn.closed:
            stage_conn.rollback()

    finally:
        if local_cursor:
            local_cursor.close()
        if local_conn:
            local_conn.close()
        if stage_cursor:
            stage_cursor.close()
        if stage_conn:
            stage_conn.close()
        logging.info("Database connections closed.")

if __name__ == "__main__":
    migrate_data()


