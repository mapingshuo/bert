#!/bin/bash

set -xe

while true ; do
  case "$1" in
    -local) is_local="$2" ; shift 2 ;;
    *)
       if [[ ${#1} > 0 ]]; then
          echo "not supported arugments ${1}" ; exit 1 ;
       else
           break
       fi
       ;;
  esac
done

case "$is_local" in
    n) is_distributed="--is_distributed true" ;;
    y) is_distributed="--is_distributed false" ;;
    *) echo "not support argument -local: ${is_local}" ; exit 1 ;;
esac

export FLAGS_fraction_of_gpu_memory_to_use=0.99
export FLAGS_eager_delete_tensor_gb=0
#export GLOG_vmodule=executor_gc_helper=2
export CUDA_VISIBLE_DEVICES=5

source ~/.runrc

# pretrain config
SAVE_STEPS=10000
BATCH_SIZE=4096
LR_RATE=1e-5
WEIGHT_DECAY=0.01
MAX_LEN=128
#TRAIN_DATA_DIR=data/train
#VALIDATION_DATA_DIR=data/validation
#CONFIG_PATH=data/demo_config/bert_config.json

#TRAIN_DATA_DIR=data/train/
#VALIDATION_DATA_DIR=data/validation/
TRAIN_DATA_DIR=/ssd2/mapingshuo/dataset/wikipedia_small_seq128/
CONFIG_PATH=bert_large/bert_config.json
VOCAB_PATH=bert_large/vocab.txt
#VOCAB_PATH=data/demo_config/vocab.txt

# Change your train arguments:

/home/mapingshuo/paddle_release_home/python-distribute/bin/python -u ./train.py ${is_distributed}\
        --use_cuda true\
        --weight_sharing true\
        --batch_size ${BATCH_SIZE} \
        --data_dir ${TRAIN_DATA_DIR} \
        --bert_config_path ${CONFIG_PATH} \
        --vocab_path ${VOCAB_PATH} \
        --generate_neg_sample true\
        --checkpoints ./output \
        --save_steps ${SAVE_STEPS} \
        --learning_rate ${LR_RATE} \
        --weight_decay ${WEIGHT_DECAY:-0} \
        --max_seq_len ${MAX_LEN} \
        --skip_steps 20 \
        --validation_steps 1000 \
        --num_iteration_per_drop_scope 10 \
        --use_fp16 false \
        --loss_scaling 8.0
       
