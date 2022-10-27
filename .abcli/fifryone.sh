#! /usr/bin/env bash

function yolov5_fiftyone() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 fiftyone <object-name> [type=yolov5]" \
            "browse <object-name>."
        return
    fi

    local object_name=$(abcli_clarify_object $1 .)

    local options=$2
    local type=$(abcli_option "$options" type yolov5)

    if [ "$type" == "yolov5" ] ; then
        abcli_log "fiftyone.browse($type:$object_name)"

        fiftyone app view \
            --dataset-dir $abcli_object_root/$object_name \
            --type fiftyone.types.YOLOv5Dataset

        return
    fi

    abcli_error "-yolov5: fiftyone: $type: type not found."
}
