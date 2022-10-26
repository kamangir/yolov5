#! /usr/bin/env bash

function yolov5_dataset() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 dataset crop$ABCUL<class_1,class_2>" \
            "crop $abcli_object_name to <class_1,class_2>."
        abcli_show_usage "yolov5 dataset split" \
            "split $abcli_object_name."
        return
    fi

    if [ "$task" == "crop" ] ; then
        local class_names=$2

        abcli_log "yolov5.dataset.crop($abcli_object_name): $class_names"
        python3 -m yolov5.dataset \
            crop \
            --class_names "$class_names" \
            --path $abcli_object_path \
            ${@:3}
        return
    fi

    if [ "$task" == "split" ] ; then
        abcli_log "yolov5.dataset.split($abcli_object_name)"

        mv -v images images_
        mv -v labels labels_

        python3 -m yolov5.dataset \
            split \
            --path $abcli_object_path \
            ${@:2}

        rm -rvf images_
        rm -rvf labels_

        return
    fi

    abcli_log_error "-yolov5: dataset: $task: command not found."
}
