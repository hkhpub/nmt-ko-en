# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

copy_data_dir=/home/hkh/data/ted2013/data.ko-en
data_dir=/home/hkh/data/ted2013/data.ste.ko-en
koen_fbase=train.ko-en

mkdir -p ${data_dir}
cp ${copy_data_dir}/${koen_fbase}.tok.clean.?? ${data_dir}/
cd ${data_dir}

for lang in ko en; do
  cat ${koen_fbase}.tok.clean.${lang} | \
  ${tools_dir}/mosesdecoder/scripts/tokenizer/detokenizer.perl -l en > ${koen_fbase}.detok.${lang}
done

# Learn Shared STE (Google Tensor2Tensor's SubwordTextEncoder)
echo "Learning STE with 32000, (Google Tensor2Tensor's SubwordTextEncoder)"
cat "${koen_fbase}.detok.ko" "${koen_fbase}.detok.en" | \
python ${tools_dir}/ste_tokenizer/learn_ste.py "vocab.ste32k.shared"

echo "Apply STE with 32000 to tokenized files..."
for lang in ko en; do
  outfile=${koen_fbase}.ste32k.${lang}
  python ${tools_dir}/ste_tokenizer/encode_ste.py "vocab.ste32k.shared" < ${koen_fbase}.detok.${lang} > "${outfile}"
done

echo "All done."
