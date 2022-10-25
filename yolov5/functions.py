from tqdm import *
from . import NAME
from abcli import file
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def adjust_yaml(filename):
    """adjust yaml.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    logger.info(f"{NAME}.adjust_yaml({filename})")

    success, dataset_yaml = file.load_yaml(filename)
    if not success:
        return success

    dataset_yaml["path"] = file.path(filename)
    dataset_yaml["val"] = "images/val"

    return file.save_yaml(filename, dataset_yaml)
