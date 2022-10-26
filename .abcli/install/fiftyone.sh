#! /usr/bin/env bash

function abcli_install_fiftyone() {
    pip3 uninstall fiftyone
    pip3 install fiftyone
}

abcli_install_module fiftyone 101