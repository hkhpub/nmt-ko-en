# Created by hkh at 2018-12-07

tools_dir=/home/hkh/tools

NMT_DIR=/home/hkh/sources/nmt-ko-en
DATA_DIR=/home/hkh/data/ted2013-bt/data.ko-en
MODEL_DIR=/home/hkh/data/ted2013-bt/data.ko-en/bpe32k.bilingual.ko-en

BILINGUAL_DIR="/home/hkh/data/ted2013/data.bilingual.ko-en"
TRAIN_SRC="$BILINGUAL_DIR/train.bilingual.tok.clean.bpe32k.ko"
TRAIN_TGT="$BILINGUAL_DIR/train.bilingual.tok.clean.bpe32k.en"

# Create vocabulary file for BPE
cat $TRAIN_SRC | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > $BILINGUAL_DIR/vocab.bpe32k

cp $BILINGUAL_DIR/vocab.bpe32k $BILINGUAL_DIR/vocab.bpe32k.ko
cp $BILINGUAL_DIR/vocab.bpe32k $BILINGUAL_DIR/vocab.bpe32k.en

cd $NMT_DIR

nohup python -m nmt.nmt \
--src=ko \
--tgt=en \
--vocab_prefix=${DATA_DIR}/vocab.bpe32k \
--train_prefix=${BILINGUAL_DIR}/train.bilingual.tok.clean.bpe32k \
--dev_prefix=${DATA_DIR}/tst2016.en-ko.tok.bpe32k \
--test_prefix=${DATA_DIR}/tst2017.en-ko.tok.bpe32k \
--out_dir=${MODEL_DIR} \
--hparams_path=hparams/ted2013_gnmt_100k.json > /tmp/bpe32k.bilingual.txt &

tail -f /tmp/bpe32k.bilingual.txt


