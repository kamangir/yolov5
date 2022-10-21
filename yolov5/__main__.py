import argparse
from . import *
from abcli import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(NAME, description=f"{NAME}-{VERSION}")
parser.add_argument(
    "task",
    type=str,
    default="",
    help="adjust_yaml|crop_dataset|split_dataset",
)
parser.add_argument(
    "--class_names",
    type=str,
    default="",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--image_extension",
    type=str,
    default="*",
)
parser.add_argument(
    "--path",
    type=str,
    default="",
)
parser.add_argument(
    "--val_size",
    type=float,
    default=0.2,
)
parser.add_argument(
    "--verbose",
    type=int,
    default=0,
    help="0|1",
)
args = parser.parse_args()

success = False
if args.task == "adjust_yaml":
    success = adjust_yaml(
        args.filename,
    )
elif args.task == "crop_dataset":
    success = crop_dataset(
        args.path,
        args.class_names,
    )
elif args.task == "split_dataset":
    success = split_dataset(
        args.path,
        val_size=args.val_size,
        image_extension=args.image_extension,
        verbose=args.verbose,
    )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
