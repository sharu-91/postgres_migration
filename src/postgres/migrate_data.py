import psycopg2
import json
import logging
import io

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

from src.postgres.config import LOCAL_DB, STAGE_DB

# Hardcoded list of tables to migrate
TABLES_TO_MIGRATE = [
    "annotation_configs",
    "dataset_examples",
    "dataset_versions",
    "datasets",
    "document_metadata",
    "document_rows",
    "documents_768",
    "embedding_collections",
    "feedback_768",
    "image_metadata",
    "mem0",
    "mem0migrations",
    "n8n_chat_histories",
    "project_sessions",
    "project_trace_retention_policies",
    "projects",
    "prompt_labels",
    "prompt_version_tags",
    "prompt_versions",
    "prompts",
    "prompts_prompt_labels",
    "rule_engine_768",
    "rule_engine_metadata",
    "rule_engine_rows",
    "rule_flow_768",
    "rule_flow_metadata",
    "rule_flows_rows",
    "rule_mapping_768",
    "spans",
    "telecaller_customer_guidance_768",
    "telecaller_customer_guidance_rows",
    "telecaller_guidance_metadata",
    "telecaller_guidance_rows",
    "trace_annotations",
    "traces",
    "user_feed_back",
    "user_roles",
    "users"
]

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

        for table in TABLES_TO_MIGRATE:
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


