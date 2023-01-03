#! /usr/bin/env bash

function yolov5_ingest() {
    local source=$(abcli_unpack_keyword $1 help)

    if [ "$source" == "help" ] ; then
        abcli_show_usage "yolov5 ingest coco128$ABCUL[from_kaggle]" \
            "ingest coco128 yolov5 dataset."
        return
    fi

    if [ "$source" == "coco128" ] ; then
        local options=$2
        local from_kaggle=$(abcli_option_int "$options" from_kaggle 0)

        abcli_log "yolov5.ingest($source) $options"

        local current_object=$abcli_object_name

        if [ "$from_kaggle" == 1 ] ; then
            abcli_select coco128-$(abcli_string_timestamp) ~trail

            kaggle datasets download -d ultralytics/coco128
            unzip -q coco128
            rm coco128.zip
            mv -v -f coco128/* ./
            rm -rf coco128

            abcli_upload ~open,solid

            abcli_cache write \
                coco128.dataset $abcli_object_name
        fi

        abcli_select \
            $(abcli_cache read coco128.dataset) \
            ~trail

        abcli_clone $current_object

        local yaml_filename=$abcli_object_path/dataset.yaml

        cp -v \
            $abcli_path_git/yolov5/data/coco128.yaml \
            $yaml_filename

        python3 -m yolov5.dataset \
            adjust \
            --filename $yaml_filename

        return
    fi

    abcli_log_error "-yolov5: ingest: $source: source not found."
}