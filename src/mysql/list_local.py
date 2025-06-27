import mysql.connector
from src.mysql.config import MYSQL_DB

def list_local_tables():
    """Connects to the local MySQL database and lists the tables."""
    conn = None
    try:
        conn = mysql.connector.connect(**MYSQL_DB)
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        print(f"Tables in database '{MYSQL_DB['database']}' on host '{MYSQL_DB['host']}':")
        if tables:
            for table in tables:
                print(table[0])
        else:
            print("No tables found in the database.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    list_local_tables()