import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Local PostgreSQL connection details
LOCAL_DB = {
    'host': os.getenv('HOST'),
    'port': int(os.getenv('PORT')),
    'user': os.getenv('USERNAME'),
    'password': os.getenv('PASSWORD'),
    'database': os.getenv('DATABASE')
}

# Staging PostgreSQL connection details
STAGE_DB = {
    'host': os.getenv('STAGE_DB_HOST'),
    'port': int(os.getenv('STAGE_DB_PORT')),
    'user': os.getenv('STAGE_DB_USER'),
    'password': os.getenv('STAGE_DB_PASSWORD'),
    'database': os.getenv('STAGE_DB_DATABASE'),
    'keepalives': int(os.getenv('STAGE_DB_KEEPALIVES')),
    'keepalives_idle': int(os.getenv('STAGE_DB_KEEPALIVES_IDLE')),
    'keepalives_interval': int(os.getenv('STAGE_DB_KEEPALIVES_INTERVAL')),
    'keepalives_count': int(os.getenv('STAGE_DB_KEEPALIVES_COUNT')),
}

# SSH Tunnel details
SSH_TUNNEL = {
    'ssh_host': os.getenv('SSH_HOST'),
    'ssh_port': int(os.getenv('SSH_PORT')),
    'ssh_user': os.getenv('SSH_USER'),
    'ssh_key': os.getenv('SSH_KEY'),
    'remote_host': os.getenv('REMOTE_HOST'),
    'remote_port': int(os.getenv('REMOTE_PORT')),
    'local_port': int(os.getenv('LOCAL_PORT')),
}