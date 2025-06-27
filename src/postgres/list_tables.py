import psycopg2
from src.postgres.config import STAGE_DB

def list_stage_tables(output_file="tables.txt"):
    """Connects to the staging PostgreSQL database and writes the table list to a file."""
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
        with open(output_file, 'w') as f:
            for table in tables:
                f.write(f"{table[0]}\n")
        print(f"Table list saved to {output_file}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    list_stage_tables()
