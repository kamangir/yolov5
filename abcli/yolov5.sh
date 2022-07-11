#! /usr/bin/env bash

function yolov5() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        abcli_help_line "yolov5 install" \
            "install yolov5."
        abcli_help_line "yolov5 validate" \
            "validate yolov5."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m yolov5 --help
        fi

        return
    fi

    if [ "$task" == "install" ] ; then
        abcli_git install yolov5
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m yolov5 validate
        return
    fi

    abcli_log_error "-yolov5: $task: command not found."
}