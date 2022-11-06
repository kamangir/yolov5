#! /usr/bin/env bash

function yolov5_train() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "yolov5 train$ABCUL<object-name>|coco128$ABCUL[classes=<class-1+class-2>,dryrun,epochs=10,gpu_count=2,image_size=<640>,size=$YOLOV5_MODEL_SIZES,~upload]" \
            "train yolov5."

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

        local classes=$(abcli_option "$options" classes)
        if [ ! -z "$classes" ] ; then
            yolov5_dataset crop \
                $(echo "$classes" | tr + ,)
        fi

        abcli_select $current_object ~trail

        local options=$(abcli_option_default "$options" epochs 3)
    else
        abcli_download object $dataset_name
    fi

    local do_upload=$(abcli_option_int "$options" upload 1)
    local dryrun=$(abcli_option_int "$options" dryrun 0)
    local epochs=$(abcli_option_int "$options" epochs 25)
    local gpu_count=$(abcli_option "$options" gpu_count -)
    local image_size=$(abcli_option_int "$options" image_size 640)
    local size=$(abcli_option "$options" size yolov5n)

    abcli_cache write \
        $abcli_object_name.type model
    abcli_cache write \
        $abcli_object_name.model_type yolov5
    abcli_cache write \
        $abcli_object_name.size $size
    abcli_cache write \
        $abcli_object_name.epochs $epochs

    abcli_relation set \
        $abcli_object_name $dataset_name \
        trained-on

    abcli_tag set \
        $abcli_object_name \
        model,yolov5

    abcli_log "yolov5.train($dataset_name) -$size x $epochs epoch(s) on $gpu_count gpu(s)-> $abcli_object_name"

    local parallel_prefix=""
    if [ "$gpu_count" != "-" ] ; then
        local parallel_prefix="-m torch.distributed.run --nproc_per_node $gpu_count"
    fi

    # https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
    # https://github.com/pytorch/pytorch/issues/8976
    local command_line="python3 \
        $parallel_prefix \
        train.py \
        --img $image_size \
        --batch 16 \
        --epochs $epochs \
        --data $abcli_object_root/$dataset_name/dataset.yaml \
        --weights $size.pt \
        --project $abcli_object_path \
        --workers 0 \
        --name model \
        --device cpu"

    abcli_log "⚙️  $command_line"

    if [ "$dryrun" == 0 ] ; then
        pushd $abcli_path_git/yolov5 > /dev/null
        eval $command_line
        popd > /dev/null

        if [ "$do_upload" == 1 ] ; then
            abcli_upload
        fi
    fi
}