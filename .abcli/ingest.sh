#! /usr/bin/env bash

function yolov5_ingest() {
    local source=$(abcli_unpack_keyword $1 help)

    if [ "$source" == "help" ] ; then
        abcli_show_usage "yolov5 ingest coco128" \
            "ingest coco128 yolov5 dataset."
        return
    fi

    if [ "$source" == "coco128" ] ; then
        abcli_log "yolov5.ingest($source)"

        kaggle datasets download -d ultralytics/coco128
        unzip coco128
        rm coco128.zip
        mv -v -f coco128/* ./
        rm -rf coco128

        cp -v \
            $abcli_path_git/yolov5/data/coco128.yaml \
            ./dataset.yaml

        python3 -m yolov5.dataset \
            adjust \
            --filename $abcli_object_path/dataset.yaml

        abcli_tag set \
            $abcli_object_name \
            dataset,coco128

        return
    fi

    abcli_error "-yolov5: ingest: $source: source not found."
}