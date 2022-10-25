#! /usr/bin/env bash

function yolov5() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        yolov5_dataset $@
        yolov5_detect $@

        abcli_show_usage "yolov5 sync_fork" \
            "sync yolov5 w/ upstream."

        yolov5_train $@

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m yolov5 --help
        fi

        return
    fi

    local function_name="yolov5_$task"
    if [[ $(type -t $function_name) == "function" ]] ; then
        $function_name ${@:2}
        return
    fi

    if [ "$task" == "sync_fork" ] ; then
        abcli_git sync_fork \
            yolov5 \
            master
        return
    fi

    abcli_log_error "-yolov5: $task: command not found."
}