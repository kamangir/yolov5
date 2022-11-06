#! /usr/bin/env bash

function yolov5_train() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 train$ABCUL<object-name>|coco128$ABCUL[dryrun,epochs=10,gpu_count=2,size=$YOLOV5_MODEL_SIZES]" \
            "train yolov5 on <object-name>|coco128."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            pushd $abcli_path_git/yolov5 > /dev/null
            python3 train.py --help
            popd > /dev/null
        fi

        return
    fi

    local dataset_name=$(abcli_clarify_object $1)

    local options=$2

    if [ "$dataset_name" == "coco128" ] ; then
        local current_object=$abcli_object_name

        abcli_select - ~trail
        yolov5_ingest coco128
        local dataset_name=$abcli_object_name

        abcli_select $current_object ~trail

        local options=$(abcli_option_default "$options" epochs 3)
    else
        abcli_download object $dataset_name
    fi

    local dryrun=$(abcli_option_int "$options" dryrun 0)
    local epochs=$(abcli_option_int "$options" epochs 25)
    local gpu_count=$(abcli_option "$options" gpu_count -)
    local size=$(abcli_option "$options" size yolov5s)

    abcli_cache write \
        $abcli_object_name.type model
    abcli_cache write \
        $abcli_object_name.model_type Yolov5
    abcli_cache write \
        $abcli_object_name.size $size
    abcli_cache write \
        $abcli_object_name.epochs $epochs

    abcli_relation set $abcli_object_name $dataset_name trained-on

    abcli_log "yolov5.train($dataset_name) -$size x $epochs epoch(s) on $gpu_count gpu(s)-> $abcli_object_name"

    local parallel_prefix=""
    if [ "$gpu_count" != "-" ] ; then
        local parallel_prefix="-m torch.distributed.run --nproc_per_node $gpu_count"
    fi

    # https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
    # https://github.com/pytorch/pytorch/issues/8976
    local command_line="python \
        $parallel_prefix \
        train.py \
        --img 80 \
        --batch 16 \
        --epochs $epochs \
        --data $abcli_object_root/$dataset_name/dataset.yaml \
        --weights $size.pt \
        --project $abcli_object_path \
        --workers 0 \
        --name model \
        --device cpu"

    if [ "$dryrun" == 0 ] ; then
        pushd $abcli_path_git/yolov5 > /dev/null
        eval $command_line
        popd > /dev/null
    else
        abcli_log $command_line
    fi
}