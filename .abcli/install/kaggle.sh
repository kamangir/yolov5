#! /usr/bin/env bash

function abcli_install_kaggle() {
    # https://github.com/Kaggle/kaggle-api
    pip3 install kaggle

    mkdir -p ~/.kaggle/
    cp -v \
        $abcli_path_bash/bootstrap/config/kaggle.json \
        ~/.kaggle/
    chmod 600 ~/.kaggle/kaggle.json
}

abcli_install_module kaggle 101