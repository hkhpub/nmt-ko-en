# Created by hkh at 2019-02-12
# zh, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/zh-en/train.zh-en.[zh|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
echo "Kwangho's rock! ^_^"

MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.zh-en
zhen_dir=/home/hkh/data/ted2013/zh-en
zhen_fbase=train.zh-en

mkdir -p ${data_dir}
cp ${zhen_dir}/${zhen_fbase}.* ${data_dir}/

cd ${data_dir}

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

# Tokenize Chinese data
echo "Tokenizing Chinese ${zhen_fbase}.zh"
${tools_dir}/stanford-segmenter/segment.sh -3 ctb ${zhen_fbase}.zh UTF8 0 > ${zhen_fbase}.tok.zh

# Tokenize English data
echo "Tokenizing English ${zhen_fbase}.en"
cat ${zhen_fbase}.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${zhen_fbase}.tok.en &
wait

# Truecase English data
echo "Truecasing English data..."
${tools_dir}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus ${zhen_fbase}.tok.en
${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${zhen_fbase}.tok.en > ${zhen_fbase}.truecase.tok.en
mv ${zhen_fbase}.truecase.tok.en ${zhen_fbase}.tok.en

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${zhen_fbase}.tok zh en "${zhen_fbase}.tok.clean" 1 $MAX_SEN_LEN

# Learn Shared BPE
echo "Learning BPE with 32000. This may take a while..."
cat "${zhen_fbase}.tok.clean.zh" "${zhen_fbase}.tok.clean.en" | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in zh en; do
  outfile=${zhen_fbase}.tok.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${zhen_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${zhen_fbase}.tok.clean.bpe32k.zh" "${zhen_fbase}.tok.clean.bpe32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

cp vocab.bpe32k vocab.bpe32k.zh
cp vocab.bpe32k vocab.bpe32k.en

echo "All done."