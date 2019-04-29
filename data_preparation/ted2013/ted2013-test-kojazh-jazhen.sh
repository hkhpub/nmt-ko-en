# Created by hkh at 2018-12-10
# ko, zh (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ko-zh/train.ko-zh.[ko|zh]
#           /home/hkh/data/ted2013/ko-ja/train.ko-ja.[ko|ja]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
#           /home/hkh/data/ted2013/zh-en/train.zh-en.[zh|en]
echo "Kwangho's rock! ^_^ Running script: [ted2013-test-kozh-zhen.sh]"

tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.kojazh-jazhen.bpe50k
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

# Adding target language tags
echo "Adding target lang tags..."
for file in ${tst2016} ${tst2017}; do
  sed 's/^/<2en> /' ${file}.tok.ko > ${file}.tag.tok.ko
  mv ${file}.tag.tok.ko ${file}.tok.ko
done

# Apply shared BPE
echo "Apply BPE with 32000 to tok files..."
for file in ${tst2016} ${tst2017}; do
  for lang in ko en; do
    outfile=${file}.tok.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${file}.tok.${lang} > "${outfile}"
  done
  mv ${file}.tok.bpe32k.ko ${file}.tok.bpe32k.kojazh
  mv ${file}.tok.bpe32k.en ${file}.tok.bpe32k.jazhen
done
echo "All done."
