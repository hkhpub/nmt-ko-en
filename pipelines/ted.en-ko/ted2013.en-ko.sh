#@IgnoreInspection BashAddShebang
tools_dir=/home/hkh/tools
#======= EXPERIMENT SETUP ======
NAME=data.bt.en-ko
DATA_DIR="/home/hkh/data/ted2013/data.ko-en"
OUTPUT_DIR="/home/hkh/data/ted2013.bpe/$NAME"
MODEL_DIR="/home/hkh/data/ted2013.bpe/nmt_models/$NAME"
NMT_DIR=/home/hkh/sources/nmt-ko-en

mkdir -p $OUTPUT_DIR

# update these variables
SRC="en"
TGT="ko"

cd $OUTPUT_DIR

cat "$DATA_DIR/train.ko-en.tok.clean.$SRC" > train.merged.$SRC
cat "$DATA_DIR/train.ko-en.tok.clean.$TGT" > train.merged.$TGT

# learning BPE model
echo "Learning BPE with 32000. This may take a while..."
cat train.merged.$SRC train.merged.$TGT | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > bpe32k.shared

echo "Apply BPE with 32000 to tokenized files..."
for lang in ${SRC} ${TGT}; do
  outfile=train.merged.bpe32k.${lang}
  echo train.merged.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c bpe32k.shared < train.merged.${lang} > ${outfile}
done

# Create vocabulary file for BPE
cat train.merged.bpe32k.$SRC train.merged.bpe32k.$TGT | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

cp vocab.bpe32k vocab.bpe32k.$SRC
cp vocab.bpe32k vocab.bpe32k.$TGT

cd $NMT_DIR

echo "start training..."
nohup python -m nmt.nmt \
--src=$SRC \
--tgt=$TGT \
--vocab_prefix=$OUTPUT_DIR/vocab.bpe32k \
--train_prefix=$OUTPUT_DIR/train.merged.bpe32k \
--dev_prefix=${DATA_DIR}/tst2016.en-ko.tok.bpe32k \
--test_prefix=${DATA_DIR}/tst2017.en-ko.tok.bpe32k \
--out_dir=${MODEL_DIR} \
--hparams_path=hparams/ted2013_gnmt_100k.json > /tmp/out.$NAME.txt &

tail -f /tmp/out.$NAME.txt

#===== EXPERIMENT END ======
