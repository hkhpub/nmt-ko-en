# Created by hkh at 2019-02-12
# zh (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/tst2016.en-zh.[en|zh]
#           /home/hkh/data/ted2013/tst2017.en-zh.[en|zh]

tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.zh-en
org_dir=/home/hkh/data/ted2013/tst.zh-en
tst2016=tst2016.zh-en
tst2017=tst2017.zh-en

mkdir -p ${data_dir}
cp ${org_dir}/${tst2016}.* ${data_dir}/
cp ${org_dir}/${tst2017}.* ${data_dir}/

cd ${data_dir}

# Tokenize Chinese & English data
echo "Tokenizing..."
for file in ${tst2016} ${tst2017}; do
  ${tools_dir}/stanford-segmenter/segment.sh -3 ctb ${file}.zh UTF8 0 > ${file}.tok.zh &
  ${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 < ${file}.en > ${file}.tok.en &
done; wait


# Truecase English data
echo "Truecasing English data..."
for file in ${tst2016} ${tst2017}; do
  ${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.truecase.tok.en
  mv ${file}.truecase.tok.en ${file}.tok.en
done

# Apply shared BPE
echo "Apply BPE with 32000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in zh en; do
    outfile=${file}.tok.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${file}.tok.${lang} > "${outfile}"
  done
done
echo "All done."