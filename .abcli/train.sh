#! /usr/bin/env bash

function yolov5_train() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 train$ABCUL<object-name>$ABCUL[epochs=10,gpu_count=2,size=yolov5s]" \
            "train yolov5 on <object-name>."
        abcli_show_usage "yolov5 train${ABCUL}validate" \
            "validate yolov5 train."

        abcli_log_list "$YOLOV5_MODEL_SIZES" space "size(s)"
        return
    fi

    local options=$2

    local is_validate=false
    if [ "$task" == "validate" ] ; then
        abcli_select
        abcli_ingest coco128
        local dataset_name=$abcli_object_name

        abcli_select

        local is_validate=true
        local options=$(abcli_option_default "$options" epochs 3)
    else
        local dataset_name=$(abcli_clarify_object $1)
        abcli_download object $dataset_name
    fi

    local epochs=$(abcli_option_int "$options" epochs 25)
    local gpu_count=$(abcli_option "$options" gpu_count -)
    local size=$(abcli_option "$options" size yolov5s)

    abcli_cache write $abcli_object_name.type model
    abcli_cache write $abcli_object_name.model_type Yolov5
    abcli_cache write $abcli_object_name.size $size
    abcli_cache write $abcli_object_name.epochs $epochs
    abcli_cache write $abcli_object_name.validation=$is_validate

    abcli_relation set $abcli_object_name $dataset_name trained-on

    abcli_log "yolov5.train($dataset_name) -$size x $epochs epoch(s) on $gpu_count gpu(s)-> $abcli_object_name"

    local parallel_prefix=""
    if [ "$gpu_count" != "-" ] ; then
        local parallel_prefix="-m torch.distributed.run --nproc_per_node $gpu_count"
    fi

    pushd $abcli_path_git/yolov5 > /dev/null
    # https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
    python \
        $parallel_prefix \
        train.py \
        --img 640 \
        --batch 16 \
        --epochs $epochs \
        --data $abcli_object_root/$dataset_name/dataset.yaml \
        --weights $size.pt \
        --project $abcli_object_path \
        --name model
    popd > /dev/null
}