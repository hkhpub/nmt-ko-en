# Created by hkh at 2018-12-07
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/wmt19_robustness/clean-data-en-ja
mtnt_dir=/home/hkh/data/wmt19_robustness/MTNT
processed_dir=/home/hkh/data/wmt19_robustness/data.bt.en-ja
fbase=train.merged

mkdir -p $processed_dir

cd $processed_dir

# Clone Moses
if [ ! -d "${tools_dir}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${tools_dir}/mosesdecoder"
fi

# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${tools_dir}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${tools_dir}/subword-nmt"
fi

# merge train data
cat $mtnt_dir/train/train.en-ja.en $data_dir/train.en > "$fbase.en"
cat $mtnt_dir/train/train.en-ja.ja $data_dir/train.ja > "$fbase.ja"
cp $mtnt_dir/train/train.en-ja.en train.en-ja.en
cp $mtnt_dir/train/train.en-ja.ja train.en-ja.ja

# Tokenize Korean data
echo "Tokenizing Japanese data"
kytea -notags < $fbase.ja > $fbase.tok.ja
kytea -notags < $mtnt_dir/valid/valid.en-ja.ja > valid.en-ja.tok.ja
kytea -notags < $mtnt_dir/test/test.en-ja.ja > test.en-ja.tok.ja
kytea -notags < train.en-ja.ja > train.en-ja.tok.ja

# Tokenize English data
echo "Tokenizing English $fbase.en"
cat $fbase.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > $fbase.tok.en &
wait
cat $mtnt_dir/valid/valid.en-ja.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > valid.en-ja.tok.en &
wait
cat $mtnt_dir/test/test.en-ja.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > test.en-ja.tok.en &
wait
cat train.en-ja.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > train.en-ja.tok.en &
wait

# Truecase English data
echo "Truecasing English data..."
${tools_dir}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus $fbase.tok.en
${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < $fbase.tok.en > $fbase.truecase.tok.en
mv $fbase.truecase.tok.en $fbase.tok.en

# learn bpe and apply
echo "learning BPE16k shared model"
cat $fbase.tok.ja $fbase.tok.en | \
${tools_dir}/subword-nmt/learn_bpe.py -s 16000 -t > "bpe16k.shared"

# apply bpe encoding to files
echo "applying BPE16k shared model"
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < $fbase.tok.ja > $fbase.tok.bpe16k.ja
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < $fbase.tok.en > $fbase.tok.bpe16k.en
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < valid.en-ja.tok.ja > valid.en-ja.tok.bpe16k.ja
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < valid.en-ja.tok.en > valid.en-ja.tok.bpe16k.en
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < test.en-ja.tok.ja > test.en-ja.tok.bpe16k.ja
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < test.en-ja.tok.en > test.en-ja.tok.bpe16k.en
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < train.en-ja.tok.ja > train.en-ja.tok.bpe16k.ja
${tools_dir}/subword-nmt/apply_bpe.py -c "bpe16k.shared" < train.en-ja.tok.en > train.en-ja.tok.bpe16k.en

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl "$fbase.tok.bpe16k" en ja "$fbase.tok.clean.bpe16k" 1 $MAX_SEN_LEN

# Create vocabulary file for SPM
cat "$fbase.tok.clean.bpe16k.ja" "$fbase.tok.clean.bpe16k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe16k
cp vocab.bpe16k vocab.bpe16k.ja
cp vocab.bpe16k vocab.bpe16k.en

echo "All done."
