# Created by hkh at 2018-12-10
# ko, zh (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ko-zh/train.ko-zh.[ko|zh]
#           /home/hkh/data/ted2013/zh-en/train.zh-en.[zh|en]
echo "Kwangho's rock! ^_^ Running script: [ted2013-train-kozh-zhen.sh]"

MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.kozh-zhen
koen_dir=/home/hkh/data/ted2013/ko-en
kozh_dir=/home/hkh/data/ted2013/ko-zh
zhen_dir=/home/hkh/data/ted2013/zh-en

koen_fbase=train.ko-en
kozh_fbase=train.ko-zh
zhen_fbase=train.zh-en

mkdir -p ${data_dir}
cp ${koen_dir}/${koen_fbase}.* ${data_dir}/
cp ${kozh_dir}/${kozh_fbase}.* ${data_dir}/
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

# Tokenize Korean data
echo "Tokenizing Korean ${koen_fbase}.ko"
python ${tools_dir}/komoran_morph.py < ${koen_fbase}.ko > ${koen_fbase}.tok.ko
python ${tools_dir}/komoran_morph.py < ${kozh_fbase}.ko > ${kozh_fbase}.tok.ko

# Tokenize Chinese data
echo "Tokenizing Chinese..."
${tools_dir}/stanford-segmenter/segment.sh -3 ctb ${kozh_fbase}.zh UTF8 0 > ${kozh_fbase}.tok.zh
${tools_dir}/stanford-segmenter/segment.sh -3 ctb ${zhen_fbase}.zh UTF8 0 > ${zhen_fbase}.tok.zh

# Tokenize English data
echo "Tokenizing English..."
cat ${koen_fbase}.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${koen_fbase}.tok.en &

echo "Tokenizing English..."
cat ${zhen_fbase}.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${zhen_fbase}.tok.en &
wait

# Truecase English data
echo "Truecasing English data..."
cat ${koen_fbase}.tok.en ${zhen_fbase}.tok.en > "corpus.tok.en"
${tools_dir}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus corpus.tok.en
for file in ${koen_fbase} ${zhen_fbase}; do
  ${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.truecase.tok.en
  mv ${file}.truecase.tok.en ${file}.tok.en
done

# Adding target language tags
echo "Adding target lang tags..."
sed 's/^/<2en> /' ${koen_fbase}.tok.ko > ${koen_fbase}.tag.tok.ko
sed 's/^/<2zh> /' ${kozh_fbase}.tok.ko > ${kozh_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${zhen_fbase}.tok.zh > ${zhen_fbase}.tag.tok.zh
mv ${koen_fbase}.tag.tok.ko ${koen_fbase}.tok.ko
mv ${kozh_fbase}.tag.tok.ko ${kozh_fbase}.tok.ko
mv ${zhen_fbase}.tag.tok.zh ${zhen_fbase}.tok.zh

echo "Merging data files..."
merge_fbase=train.merge
cat ${koen_fbase}.tok.ko ${kozh_fbase}.tok.ko ${zhen_fbase}.tok.zh > "${merge_fbase}.tok.kozh"
cat ${koen_fbase}.tok.en ${kozh_fbase}.tok.zh ${zhen_fbase}.tok.en > "${merge_fbase}.tok.zhen"

# Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${merge_fbase}.tok "kozh" "zhen" "${merge_fbase}.tok.clean" 1 $MAX_SEN_LEN

# Learn Shared BPE
echo "Learning BPE with 32000. This may take a while..."
cat "${merge_fbase}.tok.clean.kozh" "${merge_fbase}.tok.clean.zhen" | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in kozh zhen; do
  outfile=${merge_fbase}.tok.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${merge_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${merge_fbase}.tok.clean.bpe32k.kozh" "${merge_fbase}.tok.clean.bpe32k.zhen" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

cp vocab.bpe32k vocab.bpe32k.kozh
cp vocab.bpe32k vocab.bpe32k.zhen

echo "All done."