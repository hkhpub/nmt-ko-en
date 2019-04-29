#@IgnoreInspection BashAddShebang
tools_dir=/home/hkh/tools
#======= EXPERIMENT SETUP ======
NAME=data.bpe16k.en-ja
DATA_DIR="/home/hkh/data/wmt19_robustness/data.bt.en-ja"
MODEL_DIR="/home/hkh/data/wmt19_enja/nmt_models/$NAME"
NMT_DIR=/home/hkh/sources/nmt-ko-en

# update these variables
SRC="en"
TGT="ja"

cd $NMT_DIR

echo "start training..."
nohup python -m nmt.nmt \
--src=$SRC \
--tgt=$TGT \
--vocab_prefix=$DATA_DIR/vocab.bpe16k \
--train_prefix=$DATA_DIR/train.merged.tok.clean.bpe16k \
--dev_prefix=${DATA_DIR}/valid.en-ja.tok.bpe16k \
--test_prefix=${DATA_DIR}/test.en-ja.tok.bpe16k \
--out_dir=${MODEL_DIR} \
--hparams_path=hparams/wmt19_enja/gnmt_bt_200k.json > /tmp/out.$NAME.txt &

tail -f /tmp/out.$NAME.txt

#===== EXPERIMENT END ======
