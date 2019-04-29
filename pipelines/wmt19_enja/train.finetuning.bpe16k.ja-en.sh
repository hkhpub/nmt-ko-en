#@IgnoreInspection BashAddShebang
tools_dir=/home/hkh/tools
#======= EXPERIMENT SETUP ======
NAME=data.bpe16k.finetune.ja-en
DATA_DIR="/home/hkh/data/wmt19_robustness/data.en-ja"
MODEL_DIR="/home/hkh/data/wmt19_enja/nmt_models/$NAME"
NMT_DIR=/home/hkh/sources/nmt-ko-en

# update these variables
SRC="ja"
TGT="en"

cd $NMT_DIR

echo "start training..."
nohup python -m nmt.nmt \
--src=$SRC \
--tgt=$TGT \
--vocab_prefix=$DATA_DIR/vocab.bpe16k \
--train_prefix=$DATA_DIR/train.ja-en.tok.clean.bpe16k \
--dev_prefix=${DATA_DIR}/valid.ja-en.tok.bpe16k \
--test_prefix=${DATA_DIR}/test.ja-en.tok.bpe16k \
--out_dir=${MODEL_DIR} \
--hparams_path=hparams/wmt19_enja/gnmt_finetuning_1epoch.json \
--override_loaded_hparams=True > /tmp/out.$NAME.txt &

tail -f /tmp/out.$NAME.txt

#===== EXPERIMENT END ======
