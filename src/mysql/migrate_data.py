import psycopg2
import mysql.connector
import logging
import io

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

from src.mysql.config import MYSQL_DB, LOCAL_DB

def get_tables_to_migrate(file_path="tables.txt"):
    """Reads the list of tables to migrate from a file."""
    with open(file_path, 'r') as f:
        tables = [line.strip() for line in f.readlines()]
    return tables

def migrate_data_with_copy(mysql_cursor, pg_cursor, table):
    logging.info(f"Starting migration for table: {table} using COPY")

    # Truncate the table before migrating
    logging.info(f"Truncating table {table} in postgres database.")
    pg_cursor.execute(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE")
    pg_cursor.connection.commit()
    logging.info(f"Table {table} truncated.")

    # Fetch data from mysql table
    mysql_cursor.execute(f"SELECT * FROM {table}")

    # Use an in-memory buffer
    buffer = io.StringIO()
    for row in mysql_cursor:
        processed_row = []
        for value in row:
            if value is None:
                processed_row.append('\\N')
            else:
                # Replace characters that can break COPY format
                processed_row.append(str(value).replace('\t', ' ').replace('\n', ' ').replace('\r', ' '))
        buffer.write('\t'.join(processed_row) + '\n')
    buffer.seek(0)

    # Upload to staging table
    pg_cursor.copy_expert(f"COPY {table} FROM STDIN", buffer)
    pg_cursor.connection.commit()

    logging.info(f"Successfully migrated data to {table} using COPY.")

def migrate_data(tables_to_migrate=None):
    mysql_conn = None
    pg_conn = None
    mysql_cursor = None
    pg_cursor = None
    try:
        # Connect to mysql and postgres databases
        logging.info("Connecting to mysql database...")
        mysql_conn = mysql.connector.connect(**MYSQL_DB)
        mysql_cursor = mysql_conn.cursor()
        logging.info("Successfully connected to mysql database.")

        logging.info("Connecting to postgres database...")
        pg_conn = psycopg2.connect(**LOCAL_DB)
        pg_cursor = pg_conn.cursor()
        logging.info("Successfully connected to postgres database.")

        if tables_to_migrate is None:
            tables_to_migrate = get_tables_to_migrate()
        for table in tables_to_migrate:
            try:
                migrate_data_with_copy(mysql_cursor, pg_cursor, table)

            except Exception as e:
                logging.error(f"An error occurred during migration for table {table}: {e}")
                if pg_conn and not pg_conn.closed:
                    pg_conn.rollback()
                logging.info(f"Aborting migration for table {table} and continuing to the next one.")


    except Exception as e:
        logging.error(f"A critical error occurred: {e}")
        if pg_conn and not pg_conn.closed:
            pg_conn.rollback()

    finally:
        if mysql_cursor:
            mysql_cursor.close()
        if mysql_conn:
            mysql_conn.close()
        if pg_cursor:
            pg_cursor.close()
        if pg_conn:
            pg_conn.close()
        logging.info("Database connections closed.")

if __name__ == "__main__":
    migrate_data()