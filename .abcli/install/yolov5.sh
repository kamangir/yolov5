#! /usr/bin/env bash

function abcli_install_yolov5() {
    pushd $abcli_path_git/yolov5 > /dev/null
    pip3 install -r requirements.txt
    popd > /dev/null
}

abcli_install_module yolov5 101