from flask import Blueprint, render_template
from python_report_generator.log_parser import parse_logs
from config import LOGS_DIR

main = Blueprint('main', __name__)

@main.route('/')
def index():
    server_records, fail_counts, fail_messages = parse_logs(LOGS_DIR)
    return render_template('index.html', 
                           server_records=server_records, 
                           fail_counts=fail_counts, 
                           fail_messages=fail_messages)