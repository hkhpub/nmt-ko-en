# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

copy_data_dir=/home/hkh/data/ted2013/data.ko-en
data_dir=/home/hkh/data/ted2013/data.ste.ko-en
train_fbase=train.ko-en
tst2016_fbase=tst2016.en-ko
tst2017_fbase=tst2017.en-ko

mkdir -p ${data_dir}
cp ${copy_data_dir}/${train_fbase}.tok.clean.?? ${data_dir}/
cp ${copy_data_dir}/${tst2016_fbase}.tok.?? ${data_dir}/
cp ${copy_data_dir}/${tst2017_fbase}.tok.?? ${data_dir}/
cd ${data_dir}

for lang in ko en; do
  cat ${train_fbase}.tok.clean.${lang} | \
  ${tools_dir}/mosesdecoder/scripts/tokenizer/detokenizer.perl -l ${lang} > ${train_fbase}.detok.${lang}

  cat ${tst2016_fbase}.tok.${lang} | \
  ${tools_dir}/mosesdecoder/scripts/tokenizer/detokenizer.perl -l ${lang} > ${tst2016_fbase}.detok.${lang}

  cat ${tst2017_fbase}.tok.${lang} | \
  ${tools_dir}/mosesdecoder/scripts/tokenizer/detokenizer.perl -l ${lang} > ${tst2017_fbase}.detok.${lang}
done

echo "All done."
