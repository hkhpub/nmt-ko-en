# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/tst2016.en-ko.[en|ko]
#           /home/hkh/data/ted2013/tst2017.en-ko.[en|ko]
echo "Kwangho's rock! ^_^"

tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.koja-en
org_dir=/home/hkh/data/ted2013/tst.en-ko
tst2016=tst2016.en-ko
tst2017=tst2017.en-ko

mkdir -p ${data_dir}
cp ${org_dir}/${tst2016}.* ${data_dir}/
cp ${org_dir}/${tst2017}.* ${data_dir}/

cd ${data_dir}

# Tokenize Korean data
echo "Tokenizing..."
for file in ${tst2016} ${tst2017}; do
  python ${tools_dir}/komoran_morph.py < ${file}.ko > ${file}.tok.ko
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
  for lang in ko en; do
    outfile=${file}.tok.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${file}.tok.${lang} > "${outfile}"
  done
  mv ${file}.tok.bpe32k.ko ${file}.tok.bpe32k.koja
done
echo "All done."