# System support
import sys
import time 
import subprocess

# Create a Flask-SQLAlchemy app context within which to execute
# the command
from ubicity.app import app
import logging
logger = logging.getLogger(__name__)

def is_alive(host):
    """Check if a host is alive by executing a simple ping command. We
    retry for about a minute on success to make sure the host has
    sufficient time to come up
    """
    success_retries = 12
    success_sleep = 5
    successes = 0
    failure_retries = 3
    failure_sleep = 1
    failures = 0
    while True:
        try:
            output = subprocess.check_output(f"ping -c 1 {host}", shell=True)
            # output = subprocess.check_output(f"nc -w 3 -z {host} 22", shell=True)
            failures = 0
            successes += 1
            delay_value = success_sleep
            if successes == success_retries:
                return True
        except subprocess.CalledProcessError as e:
            logger.debug(f"Command: {e.cmd} failed")
            logger.debug(f"Return code: {e.returncode}")
            logger.debug(f"Output: {e.output}")
            logger.debug(f"Error output: {e.stderr}")
            logger.debug(f"Successes: {successes} - Failures: {failures}")
            successes = 0
            failures += 1
            delay_value = failure_sleep
            if failures == failure_retries:
                return False
        time.sleep(delay_value)

def main():
    host_name = sys.argv[1]
    host = sys.argv[2]
    node_id = sys.argv[3]

    while True:
        if is_alive(host):
            with app.app_context():
                import ubicity.actions.node
                response = ubicity.actions.node.on_healthy(node_id)
                pass
        else:
            with app.app_context():
                import ubicity.actions.node
                response = ubicity.actions.node.on_error(node_id)
                pass
        time.sleep(15)
            

if __name__ == "__main__":
    main()
