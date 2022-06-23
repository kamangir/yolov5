#! /usr/bin/env bash

function yolov5() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        bolt_help_line "yolov5 terraform" \
            "terraform yolov5."
        bolt_help_line "yolov5 validate" \
            "validate yolov5."

        if [ "$(bolt_keyword_is $2 verbose)" == true ] ; then
            python3 -m yolov5 --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        bolt_git terraform yolov5
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m yolov5 validate
        return
    fi

    bolt_log_error "unknown task: yolov5 '$task'."
}