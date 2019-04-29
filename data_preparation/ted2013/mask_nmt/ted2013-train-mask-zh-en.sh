# Created by hkh at 2019-02-12
# zh (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/zh-en/train.zh-en.[zh|en]
MAX_SEN_LEN=50
base_dir=/home/hkh/sources/nmt-ko-en
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.mask.zh-en
zhen_fbase=train.zh-en

mkdir -p ${data_dir}
cp -r ${data_dir}/../data.zh-en/* ${data_dir}/
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

## English pos tagging
#java -mx3000m -classpath ${tools_dir}/stanford-postagger-full/stanford-postagger.jar \
#edu.stanford.nlp.tagger.maxent.MaxentTagger \
#-model ${tools_dir}/stanford-postagger-full/models/english-left3words-distsim.tagger \
#-tagSeparator \| -tokenize False -textFile ${zhen_fbase}.tok.en > ${zhen_fbase}.tag.en
#
## Chinese pos tagging
#java -mx3000m -classpath ${tools_dir}/stanford-postagger-full/stanford-postagger.jar \
#edu.stanford.nlp.tagger.maxent.MaxentTagger \
#-model ${tools_dir}/stanford-postagger-full/models/chinese-distsim.tagger \
#-tagSeparator \| -tokenize False -textFile ${zhen_fbase}.tok.zh > ${zhen_fbase}.tag.zh

# Masking
echo "Masking corpora..."
python ${base_dir}/tools/masking/english_masking.py < "${zhen_fbase}.tag.en" > "${zhen_fbase}.mask.en"
python ${base_dir}/tools/masking/chinese_masking.py < "${zhen_fbase}.tag.zh" > "${zhen_fbase}.mask.zh"

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${zhen_fbase}.mask zh en "${zhen_fbase}.mask.clean" 1 $MAX_SEN_LEN

# Learn Shared BPE
echo "Learning BPE with 32000. This may take a while..."
cat "${zhen_fbase}.mask.clean.zh" "${zhen_fbase}.mask.clean.en" | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.mask.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in zh en; do
  outfile=${zhen_fbase}.mask.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.mask.shared" < ${zhen_fbase}.mask.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${zhen_fbase}.mask.clean.bpe32k.zh" "${zhen_fbase}.mask.clean.bpe32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.mask.bpe32k

python ${base_dir}/tools/masking/merg_vocab.py \
--input1=${data_dir}/vocab.bpe32k \
--input2=${data_dir}/vocab.mask.bpe32k \
--output=${data_dir}/vocab.merged.bpe32k

cp vocab.merged.bpe32k vocab.merged.bpe32k.zh
cp vocab.merged.bpe32k vocab.merged.bpe32k.en

echo "All done."