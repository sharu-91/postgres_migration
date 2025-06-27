# How to Run This Project

This document provides instructions on how to set up and run the database utility scripts.

## Prerequisites

1.  **Python 3.x**: Ensure you have Python 3.x installed.
2.  **uv**: This project uses `uv` for package management. Install it if you haven't already:
    ```bash
    pip install uv
    ```
3.  **PostgreSQL Client**: `psycopg2` requires PostgreSQL client libraries. Ensure they are installed on your system.
    *   On Debian/Ubuntu: `sudo apt-get install libpq-dev postgresql-client`
    *   On macOS (using Homebrew): `brew install postgresql libpq` (ensure `pg_dump` from the installed PostgreSQL is in your PATH)
    *   On Windows: Install the PostgreSQL binaries which include `pg_dump`.
4.  **MySQL Client**: `mysql-connector-python` requires MySQL client libraries. Ensure they are installed on your system.
    *   On Debian/Ubuntu: `sudo apt-get install default-libmysqlclient-dev`
    *   On macOS (using Homebrew): `brew install mysql-client`
    *   On Windows: Install the MySQL Installer, which includes the client libraries.
5.  **SSH Access (for Stage Database)**: If you intend to connect to the stage database and it's behind an SSH tunnel (as configured by default in `.env`), ensure you have SSH access to the tunnel server and the tunnel is active. The `.env` file contains an example SSH command.

## Setup

1.  **Clone the Repository**:
    ```bash
    # git clone <your-repository-url>
    # cd <your-project-directory>
    ```

2.  **Create a Virtual Environment (Recommended)**:
    Using `uv`:
    ```bash
    uv venv
    source .venv/bin/activate  # On macOS/Linux
    # .venv\Scripts\activate    # On Windows
    ```

3.  **Install Dependencies**:
    ```bash
    uv pip install -r requirements.txt 
    ```
    *(Note: You might need to create a `requirements.txt` file first if it doesn't exist. The necessary dependencies are `psycopg2-binary` and `python-dotenv`. You can add them using `uv add psycopg2-binary python-dotenv` which will update `pyproject.toml`, and then `uv pip freeze > requirements.txt` or `uv pip compile pyproject.toml -o requirements.txt`)*

4.  **Configure Environment Variables**:
    *   Copy the example `.env.example` to `.env` (if an example file is provided) or create a new `.env` file in the project root.
    *   Update the `.env` file with your actual database connection details for both local and stage environments, and SSH tunnel details if applicable.

    Example `.env` structure:
    ```env
    # Local PostgreSQL connection details
    HOST=your_local_db_host
    PORT=your_local_db_port
    USERNAME=your_local_db_user
    PASSWORD=your_local_db_password
    DATABASE=your_local_db_name

    # Staging PostgreSQL connection details
    STAGE_DB_HOST=localhost # or your_stage_db_host if not using SSH tunnel via localhost
    STAGE_DB_PORT=your_stage_db_port_via_tunnel_or_direct
    STAGE_DB_USER=your_stage_db_user
    STAGE_DB_PASSWORD=your_stage_db_password
    STAGE_DB_DATABASE=your_stage_db_name
    STAGE_DB_KEEPALIVES=1
    STAGE_DB_KEEPALIVES_IDLE=30
    STAGE_DB_KEEPALIVES_INTERVAL=10
    STAGE_DB_KEEPALIVES_COUNT=5

    # SSH Tunnel details (if STAGE_DB_HOST is 'localhost' and requires a tunnel)
    SSH_HOST=your_ssh_server_ip
    SSH_PORT=22
    SSH_USER=your_ssh_username
    SSH_KEY=/path/to/your/ssh/private_key # e.g., /home/user/.ssh/id_rsa
    REMOTE_HOST=actual_stage_db_ip_behind_ssh
    REMOTE_PORT=actual_stage_db_port_behind_ssh
    LOCAL_PORT=local_port_for_tunnel_to_stage_db # Should match STAGE_DB_PORT if STAGE_DB_HOST is localhost
    ```

## Running the Utility (`main.py`)

The `main.py` script provides a command-line interface to interact with the database utilities.

**General Usage**:
```bash
python main.py <command> [options]
```

### Commands:

1.  **`list-tables`**: Lists tables from the specified database.
    *   **Arguments**:
        *   `db_type`: `pg-local`, `pg-stage`, or `mysql`.
    *   **Examples**:
        ```bash
        python main.py list-tables pg-local
        python main.py list-tables pg-stage
        python main.py list-tables mysql
        ```
        *(For `pg-stage`, ensure SSH tunnel is active if configured to connect via `localhost`)*

2.  **`generate-schema`**: Generates a markdown file (`.md`) containing a **full schema dump** for the specified database.
    *   **Prerequisites**: `pg_dump` or `mysqldump` command must be installed and in your system's PATH.
    *   **Arguments**:
        *   `db_type`: `pg-local`, `pg-stage`, or `mysql`.
        *   `--output <filename>`: (Optional) Specifies the output file name.
    *   **Examples**:
        ```bash
        uv run main.py generate-schema pg-local
        uv run main.py generate-schema pg-stage --output custom_stage_schema.md
        uv run main.py generate-schema mysql
        ```
        *(For `pg-stage`, ensure SSH tunnel is active if configured to connect via `localhost`)*

3.  **`migrate`**: Migrates data from one database to another.
    *   **Important**: This operation will **TRUNCATE** tables in the destination database before migrating data.
    *   **Arguments**:
        *   `migration_type`: `pg-local-to-stage` or `mysql-to-pg-local`.
        *   `--confirm`: Required to proceed with the migration. You will be asked for a final 'yes/no' confirmation in the terminal.
        *   `--tables`: (Optional) A space-separated list of specific tables to migrate. If not provided, all tables from `tables.txt` will be migrated.
    *   **Examples**:
        ```bash
        # Migrate all tables from local PostgreSQL to stage PostgreSQL
        python main.py migrate pg-local-to-stage --confirm

        # Migrate all tables from MySQL to local PostgreSQL
        python main.py migrate mysql-to-pg-local --confirm

        # Migrate only specific tables from MySQL to local PostgreSQL
        python main.py migrate mysql-to-pg-local --confirm --tables component_log durability_log_data
        ```
        *(For `pg-local-to-stage`, ensure SSH tunnel is active if configured to connect via `localhost` for the stage database)*

### Establishing SSH Tunnel (Example)

If your stage database requires an SSH tunnel (as per the `.env` configuration for `STAGE_DB_HOST=localhost`), you need to establish it before running commands that interact with the stage database. The `.env` file contains variables like `SSH_HOST`, `SSH_USER`, `SSH_KEY`, `REMOTE_HOST`, `REMOTE_PORT`, and `LOCAL_PORT` (which should match `STAGE_DB_PORT`).

An example command to establish the tunnel (replace placeholders with values from your `.env`):
```bash
ssh -N -L ${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT} ${SSH_USER}@${SSH_HOST} -i ${SSH_KEY}
```
For example, if `LOCAL_PORT` is `5433`, `REMOTE_HOST` is `10.0.0.10`, `REMOTE_PORT` is `5432`, `SSH_USER` is `user`, `SSH_HOST` is `ssh.example.com`, and `SSH_KEY` is `~/.ssh/id_rsa`:
```bash
ssh -N -L 5433:10.0.0.10:5432 user@ssh.example.com -i ~/.ssh/id_rsa
```
Keep this tunnel running in a separate terminal window while you operate on the stage database.

## Testing

To test the functionalities:

1.  **Set up your `.env` file** correctly with connection details for a local PostgreSQL instance and (optionally, if you want to test staging features) a stage PostgreSQL instance (with SSH tunnel if needed).
2.  **List tables**:
    ```bash
    python main.py list-tables local
    python main.py list-tables stage 
    ```
3.  **Generate schema**:
    ```bash
    uv run main.py generate-schema local --output local_postgres_schema_details.md
    uv run main.py generate-schema stage --output stage_postgres_schema_details.md
    ```
    Check the generated `.md` files. They should now contain full schema dumps.
4.  **Migrate data** (Use with caution, preferably on test databases):
    Ensure your local database has some tables and data that match the tables expected by the migration script (defined in `src/postgres/migrate_data.py`'s `TABLES_TO_MIGRATE` list). Ensure the target tables exist in the stage database.
    ```bash
    python main.py migrate-data --confirm
    ```
    Follow the prompts and check the stage database for migrated data.

This should cover the setup and usage of the project.