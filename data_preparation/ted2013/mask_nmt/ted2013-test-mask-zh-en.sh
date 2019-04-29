# Created by hkh at 2019-02-12
# zh (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/zh-en/train.zh-en.[zh|en]

MAX_SEN_LEN=50
tools_dir=/home/hkh/tools
base_dir=/home/hkh/sources/nmt-ko-en

data_dir=/home/hkh/data/ted2013/data.mask.zh-en
tst2016=tst2016.zh-en
tst2017=tst2017.zh-en

cd ${data_dir}

# pos tagging & masking
echo "Pos tagging & masking..."
for file in ${tst2016} ${tst2017}; do
#  # English pos tagging
#  java -mx3000m -classpath ${tools_dir}/stanford-postagger-full/stanford-postagger.jar \
#  edu.stanford.nlp.tagger.maxent.MaxentTagger \
#  -model ${tools_dir}/stanford-postagger-full/models/english-left3words-distsim.tagger \
#  -tagSeparator \| -tokenize False -textFile ${file}.tok.en > ${file}.tag.en
#
#  # Chinese pos tagging
#  java -mx3000m -classpath ${tools_dir}/stanford-postagger-full/stanford-postagger.jar \
#  edu.stanford.nlp.tagger.maxent.MaxentTagger \
#  -model ${tools_dir}/stanford-postagger-full/models/chinese-distsim.tagger \
#  -tagSeparator \| -tokenize False -textFile ${file}.tok.zh > ${file}.tag.zh

  python ${base_dir}/tools/masking/english_masking.py < "${file}.tag.en" > "${file}.mask.en"
  python ${base_dir}/tools/masking/chinese_masking.py < "${file}.tag.zh" > "${file}.mask.zh"
done

# Apply shared BPE
echo "Apply BPE with 32000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in zh en; do
    outfile=${file}.mask.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.mask.shared" < ${file}.mask.${lang} > "${outfile}"
  done
done
echo "All done."
