import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOGS_DIR = os.path.join(BASE_DIR, 'logs')

# Ensure the logs directory exists
os.makedirs(LOGS_DIR, exist_ok=True)