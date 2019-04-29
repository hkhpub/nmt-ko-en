# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.bpe.ko-en
koen_dir=/home/hkh/data/ted2013/data.ko-en
bpe_dir=/home/hkh/data/bpe-koen

koen_fbase=train.ko-en

mkdir -p ${data_dir}
cp ${koen_dir}/${koen_fbase}.* ${data_dir}/
rm ${data_dir}/*bpe*

cd ${data_dir}

echo "Apply BPE with 32000 to tokenized files..."
for lang in ko en; do
  outfile=${koen_fbase}.tok.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "${bpe_dir}/bpe32k.koen" < ${koen_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${koen_fbase}.tok.clean.bpe32k.ko" "${koen_fbase}.tok.clean.bpe32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

cp vocab.bpe32k vocab.bpe32k.ko
cp vocab.bpe32k vocab.bpe32k.en

echo "All done."
