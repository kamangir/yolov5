from setuptools import setup

from yolov5 import name, version

setup(
    name=name,
    author="kamangir",
    version=str(version),
    description=name,
    packages=[name],
)
