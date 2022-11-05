import argparse

from . import *

parser = argparse.ArgumentParser(name, description="{}-{:.2f}".format(name, version))
parser.add_argument("task", type=str, help="TBD")
args = parser.parse_args()

success = False
if args.task == "TBD":
    success = True
else:
    print(f'error! unknown task: {name} "{args.task}".')

if not success:
    print(f"error! {name}.{args.task} failed.")
