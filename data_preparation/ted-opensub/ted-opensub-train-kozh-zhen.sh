# Created by hkh at 2018-12-11
# ko, zh (source) -> zh, en (target)
echo "Kwangho's rock! ^_^"

MIN_SEN_LEN=3
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013-outdomain/data.kozh-zhen
opensub_dir=/home/hkh/data/opensub18
ted_dir=/home/hkh/data/ted2013/train.all
tanzil_dir=/home/hkh/data/tanzil

opensub_koen_fbase=opensub.en-ko
opensub_kozh_fbase=opensub.ko-zh
opensub_zhen_fbase=opensub.en-zh
ted_koen_fbase=train.ko-en
ted_kozh_fbase=train.ko-zh
ted_zhen_fbase=train.zh-en
tanzil_zhen_fbase=tanzil.en-zh

mkdir -p ${data_dir}

# copy data
cp ${opensub_dir}/${opensub_koen_fbase}.tok.* ${data_dir}/
cp ${opensub_dir}/${opensub_kozh_fbase}.tok.* ${data_dir}/
cp ${opensub_dir}/${opensub_zhen_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_koen_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_kozh_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_zhen_fbase}.tok.* ${data_dir}/
cp ${tanzil_dir}/${tanzil_zhen_fbase}.tok.* ${data_dir}/

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

# Adding target language tags
echo "Adding target lang tags..."
sed 's/^/<2en> /' ${opensub_koen_fbase}.tok.ko > ${opensub_koen_fbase}.tag.tok.ko
sed 's/^/<2zh> /' ${opensub_kozh_fbase}.tok.ko > ${opensub_kozh_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${opensub_zhen_fbase}.tok.zh > ${opensub_zhen_fbase}.tag.tok.zh
sed 's/^/<2en> /' ${ted_koen_fbase}.tok.ko > ${ted_koen_fbase}.tag.tok.ko
sed 's/^/<2zh> /' ${ted_kozh_fbase}.tok.ko > ${ted_kozh_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${ted_zhen_fbase}.tok.zh > ${ted_zhen_fbase}.tag.tok.zh
sed 's/^/<2en> /' ${tanzil_zhen_fbase}.tok.zh > ${tanzil_zhen_fbase}.tag.tok.zh
mv ${opensub_koen_fbase}.tag.tok.ko ${opensub_koen_fbase}.tok.ko
mv ${opensub_kozh_fbase}.tag.tok.ko ${opensub_kozh_fbase}.tok.ko
mv ${opensub_zhen_fbase}.tag.tok.zh ${opensub_zhen_fbase}.tok.zh
mv ${ted_koen_fbase}.tag.tok.ko ${ted_koen_fbase}.tok.ko
mv ${ted_kozh_fbase}.tag.tok.ko ${ted_kozh_fbase}.tok.ko
mv ${ted_zhen_fbase}.tag.tok.zh ${ted_zhen_fbase}.tok.zh
mv ${tanzil_zhen_fbase}.tag.tok.zh ${tanzil_zhen_fbase}.tok.zh


echo "Merging data files..."
merge_fbase=train.merge
# merging source side resources
cat ${opensub_koen_fbase}.tok.ko \
    ${opensub_kozh_fbase}.tok.ko \
    ${opensub_zhen_fbase}.tok.zh \
    ${ted_koen_fbase}.tok.ko \
    ${ted_kozh_fbase}.tok.ko \
    ${ted_zhen_fbase}.tok.zh \
    ${tanzil_zhen_fbase}.tok.zh > "${merge_fbase}.tok.kozh"

# merging target side resources
cat ${opensub_koen_fbase}.tok.en \
    ${opensub_kozh_fbase}.tok.zh \
    ${opensub_zhen_fbase}.tok.en \
    ${ted_koen_fbase}.tok.en \
    ${ted_kozh_fbase}.tok.zh \
    ${ted_zhen_fbase}.tok.en \
    ${tanzil_zhen_fbase}.tok.en > "${merge_fbase}.tok.zhen"

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${merge_fbase}.tok kozh zhen "${merge_fbase}.tok.clean" $MIN_SEN_LEN $MAX_SEN_LEN

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

# Finalizing
mkdir -p tmp
mv ${merge_fbase}.tok.clean.bpe32k.* tmp/
mv vocab.bpe32k tmp/
mv bpe32k.shared tmp/

rm ./*
mv tmp/* ./
rm -r tmp

cp vocab.bpe32k vocab.bpe32k.kozh
cp vocab.bpe32k vocab.bpe32k.zhen

echo "All done."