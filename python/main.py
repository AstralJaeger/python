import logging
import sys
import os
import os.path
from environment import SENTRY_URL, FORMAT

root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter()
handler.setFormatter(formatter)
root.addHandler(handler)

logger = logging.getLogger(os.path.basename(__file__))
logger.info(f"Sentry DSN url: {SENTRY_URL}")
