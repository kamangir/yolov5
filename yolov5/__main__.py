import argparse
from abcli import file
from . import *
from abcli import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(NAME, description=f"{NAME}-{VERSION}")
parser.add_argument(
    "task",
    type=str,
    default="",
    help="show_version",
)
args = parser.parse_args()

success = False
if args.task == "show_version":
    success = True
    print(f"{NAME}-{VERSION}")
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
