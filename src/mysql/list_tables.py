import mysql.connector
from src.mysql.config import MYSQL_DB

def list_mysql_tables(output_file="tables.txt"):
    """Connects to the MySQL database and writes the table list to a file."""
    conn = None
    try:
        conn = mysql.connector.connect(**MYSQL_DB)
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES")
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
    list_mysql_tables()