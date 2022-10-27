import copy
import os
import random
from tqdm import *
from . import NAME
from abcli import file
from abcli.plugins import cache
import abcli.path
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def adjust_dataset(filename):
    """adjust dataset.

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

    dataset_yaml["classes"] = dataset_yaml["names"]
    del dataset_yaml["names"]

    return file.save_yaml(filename, dataset_yaml)


def crop_dataset(path, class_names):
    """crop dataset.

    Args:
        path (ste): path.
        class_names (str): class_1,class_2

    Returns:
        bool: success.
    """
    if isinstance(class_names, str):
        class_names = [
            class_name for class_name in class_names.split(",") if class_name
        ]

    if not class_names:
        logger.error(f"-{NAME}: crop_dataset: class_names not found.")
        return False

    success, dataset_yaml = file.load_yaml(os.path.join(path, "dataset.yaml"))
    if not success:
        return success

    dataset_yaml["nc"] = len(class_names)

    class_indexes = [
        str(dataset_yaml["names"].index(class_name))
        if class_name in dataset_yaml["names"]
        else None
        for class_name in class_names
    ]

    if None in class_indexes:
        logger.error(
            "-{}: crop_dataset: {}: class_name not found.".format(
                NAME,
                class_names[class_indexes.index(None)],
            )
        )
        return False

    logger.info(
        "{}: crop_dataset({}): {} - removing {}".format(
            NAME,
            path,
            ",".join(
                [
                    f"{class_name}:{class_index}->{index}"
                    for index, (class_name, class_index) in enumerate(
                        zip(class_names, class_indexes)
                    )
                ]
            ),
            ",".join(
                [
                    class_name
                    for class_name in dataset_yaml["names"]
                    if class_name not in class_names
                ]
            ),
        )
    )

    dataset_yaml["names"] = copy.deepcopy(class_names)

    list_of_files = file.list_of(
        os.path.join(os.path.join(path, "labels"), "*.*"), True
    )
    logger.info(f"found {len(list_of_files)} label(s).")
    for filename in tqdm(list_of_files):
        success, content = file.load_text(filename)
        if not success:
            return success

        content = [
            " ".join(
                [
                    str(class_indexes.index(line.split(" ")[0])),
                ]
                + line.split(" ")[1:]
            )
            for line in content
            if line.split(" ")[0] in class_indexes
        ]

        if not file.save_text(filename, content):
            return False

    return file.save_yaml(
        os.path.join(path, "dataset.yaml"),
        dataset_yaml,
    )


def split_dataset(path, val_size=0.2, image_extension="*", verbose=False):
    """split dataset.

    Args:
        path (str): path.
        val_size (float, optional): val size. Defaults to 0.2.
        image_extension (str, optional): image extension. Defaults to "*".
        verbose (bool, optional): verbose. Defaults to "*".

    Returns:
        bool: success.
    """
    path_to_images = os.path.join(path, "images_")
    list_of_files = [
        file.relative(filename, path_to_images)
        for filename in file.list_of(
            os.path.join(
                path_to_images,
                f"*.{image_extension}",
            ),
            True,
        )
    ]
    if not list_of_files:
        logger.error(f"{NAME}: split_dataset({path}): no image.")
        return False

    logger.info(f"{NAME}: split_dataset(val={val_size:.2f}): {path}")
    logger.info(f"found {len(list_of_files)} images(s).")

    list_of_subsets = {}
    list_of_subsets["val"] = random.sample(
        list_of_files, k=int(len(list_of_files) * val_size)
    )
    list_of_subsets["train"] = [
        filename for filename in list_of_files if filename not in list_of_subsets["val"]
    ]
    logger.info(
        "{}: split: {} train - {} val : {:.2f} ~= {:.2f}".format(
            NAME,
            len(list_of_subsets["train"]),
            len(list_of_subsets["val"]),
            len(list_of_subsets["val"]) / len(list_of_files),
            val_size,
        )
    )

    success, dataset_yaml = file.load_yaml(os.path.join(path, "dataset.yaml"))
    if not success:
        return success

    for subset in list_of_subsets:
        dataset_yaml[subset] = f"images/{subset}"

    if not file.save_yaml(os.path.join(path, "dataset.yaml"), dataset_yaml):
        return False

    for subfolder in "images,labels".split(","):
        if not abcli.path.create(os.path.join(path, subfolder)):
            return False
        for subset in list_of_subsets:
            if not abcli.path.create(os.path.join(path, subfolder, subset)):
                return False

            for postfix in tqdm(list_of_subsets[subset]):
                source = os.path.join(path, f"{subfolder}_", postfix)
                destination = os.path.join(
                    path, subfolder, subset, file.name_and_extension(postfix)
                )

                if subfolder == "labels":
                    source = file.set_extension(source, "txt")
                    destination = file.set_extension(destination, "txt")

                if verbose:
                    logger.info(f"{source} -> {destination}")

                if not file.move(source, destination):
                    return False

    return cache.write(
        f"{abcli.path.name(path)}.val_size",
        f"{val_size:f05}",
    )
