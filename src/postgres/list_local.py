import psycopg2
from src.postgres.config import LOCAL_DB

def list_local_tables():
    """Connects to the local PostgreSQL database and lists the tables from information_schema."""
    conn = None
    try:
        conn = psycopg2.connect(**LOCAL_DB)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        print(f"Tables in database '{LOCAL_DB['database']}' on host '{LOCAL_DB['host']}':")
        if tables:
            for table in tables:
                print(table[0])
        else:
            print("No tables found in the public schema.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    list_local_tables()
