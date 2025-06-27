import pymysql
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# MySQL connection details from .env
MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST"),
    "port": int(os.getenv("MYSQL_PORT")),
    "user": os.getenv("MYSQL_USER"),
    "password": os.getenv("MYSQL_PASSWORD"),
    "database": os.getenv("MYSQL_DATABASE"),
}

# PostgreSQL connection details from .env
PG_CONFIG = {
    "host": os.getenv("HOST"),
    "port": int(os.getenv("PORT")),
    "user": os.getenv("USERNAME"),
    "password": os.getenv("PASSWORD"),
    "database": os.getenv("DATABASE"),
}

def transfer_table(mysql_table, pg_table):
    # Connect to MySQL
    mysql_conn = pymysql.connect(**MYSQL_CONFIG)
    mysql_cur = mysql_conn.cursor()
    mysql_cur.execute(f"SELECT * FROM {mysql_table}")
    rows = mysql_cur.fetchall()
    columns = [desc[0] for desc in mysql_cur.description]

    # Connect to PostgreSQL
    pg_conn = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg_conn.cursor()

    # Prepare insert statement
    col_names = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))
    insert_sql = f"INSERT INTO {pg_table} ({col_names}) VALUES ({placeholders})"

    # Insert data into PostgreSQL
    for row in rows:
        pg_cur.execute(insert_sql, row)
    pg_conn.commit()

    print(f"Transferred {len(rows)} rows from {mysql_table} to {pg_table}")

    # Close connections
    mysql_cur.close()
    mysql_conn.close()
    pg_cur.close()
    pg_conn.close()

if __name__ == "__main__":
    # Example usage: transfer 'your_mysql_table' from MySQL to PostgreSQL
    transfer_table("your_mysql_table", "your_postgres_table")
