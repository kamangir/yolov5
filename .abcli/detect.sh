#! /usr/bin/env bash

function yolov5_detect() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 detect$ABCUL<model-object>$ABCUL<postfix>" \
            "yolov5(<model-object>).detect($abcli_object_name/<postfix>)."
        abcli_show_usage "yolov5 detect validate" \
            "validate yolov5 detection."
        return
    fi

    local postfix=$2

    if [ "$task" == "validate" ] ; then
        abcli_select
        abcli_ingest coco128

        local weights="yolov5s.pt"
        local postfix="images/train2017"
    else
        local model_object_name=$(abcli_clarify_object "$1" $(abcli_string_timestamp))
        abcli_download object $model_object_name

        local weights="$abcli_path_storage/$model_object_name/model/weights/best.pt"
    fi

    abcli_tag set $abcli_object_name yolov5_detection

    abcli_relation set $abcli_object_name $model_object_name was-detected-by

    pushd $abcli_path_git/yolov5 > /dev/null
    python detect.py \
        --weights $weights \
        --source "$abcli_object_path/$postfix/*.jpg" \
        --project $abcli_object_path \
        --name detection
    popd > /dev/null
}
