import psycopg2
from src.postgres.config import STAGE_DB

def list_stage_tables():
    """Connects to the staging PostgreSQL database and lists the tables."""
    conn = None
    try:
        conn = psycopg2.connect(**STAGE_DB)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        print(f"Tables in database '{STAGE_DB['database']}':")
        for table in tables:
            print(table[0])
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    list_stage_tables()
