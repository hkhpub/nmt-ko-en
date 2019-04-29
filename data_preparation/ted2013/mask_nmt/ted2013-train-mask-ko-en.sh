# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
MAX_SEN_LEN=50
base_dir=/home/hkh/sources/nmt-ko-en
tools_dir=/home/hkh/tools

mkdir -p ${data_dir}
data_dir=/home/hkh/data/ted2013/data.mask.ko-en
koen_fbase=train.ko-en

cp -r ${data_dir}/../data.ko-en/* ${data_dir}/
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

# pos tagging & masking
# English pos tagging
java -mx3000m -classpath ${tools_dir}/stanford-postagger-full/stanford-postagger.jar \
edu.stanford.nlp.tagger.maxent.MaxentTagger \
-model ${tools_dir}/stanford-postagger-full/models/english-left3words-distsim.tagger \
-tagSeparator \| -textFile ${koen_fbase}.tok.en > ${koen_fbase}.tags.en

#python ${base_dir}/tools/komoran_tag_morph.py < "${koen_fbase}.ko" > "${koen_fbase}.tag.ko"
python ${base_dir}/tools/masking/english_masking.py < "${koen_fbase}.tag.en" > "${koen_fbase}.mask.en"
python ${base_dir}/tools/masking/korean_masking.py < "${koen_fbase}.tag.ko" > "${koen_fbase}.mask.ko"

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${koen_fbase}.mask ko en "${koen_fbase}.mask.clean" 1 $MAX_SEN_LEN

# Learn Shared BPE
echo "Learning BPE with 32000. This may take a while..."
cat "${koen_fbase}.mask.clean.ko" "${koen_fbase}.mask.clean.en" | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.mask.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in ko en; do
  outfile=${koen_fbase}.mask.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.mask.shared" < ${koen_fbase}.mask.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${koen_fbase}.mask.clean.bpe32k.ko" "${koen_fbase}.mask.clean.bpe32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.mask.bpe32k

python ${base_dir}/tools/masking/merg_vocab.py \
--input1=${data_dir}/vocab.bpe32k \
--input2=${data_dir}/vocab.mask.bpe32k \
--output=${data_dir}/vocab.merged.bpe32k

cp vocab.merged.bpe32k vocab.merged.bpe32k.ko
cp vocab.merged.bpe32k vocab.merged.bpe32k.en

echo "All done."