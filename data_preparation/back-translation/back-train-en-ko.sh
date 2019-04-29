# Created by hkh at 2018-12-07
# ko (source) -> en (target)
MIN_SEN_LEN=3
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013-bt/data.ko-en
opensub_dir=/home/hkh/data/opensub18
ted_koen_dir=/home/hkh/data/ted2013/data.ko-en
bpe_dir=/home/hkh/data/bpe-koen

ted_koen_fbase=train.ko-en
opensub_koen_fbase=opensub.en-ko

mkdir -p ${data_dir}

# copy data
cp ${opensub_dir}/${opensub_koen_fbase}.tok.* ${data_dir}/
cp ${ted_koen_dir}/${ted_koen_fbase}.tok.* ${data_dir}/

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

echo "Merging data files..."

merge_fbase=train.merge
cat ${ted_koen_fbase}.tok.ko ${opensub_koen_fbase}.tok.ko > "${merge_fbase}.tok.ko"
cat ${ted_koen_fbase}.tok.en ${opensub_koen_fbase}.tok.en > "${merge_fbase}.tok.en"

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${merge_fbase}.tok ko en "${merge_fbase}.tok.clean" $MIN_SEN_LEN $MAX_SEN_LEN

## We have a pre-trained BPE model, I don't need this anymore
## Learn Shared BPE
#echo "Learning BPE with 32000. This may take a while..."
#cat "${merge_fbase}.tok.clean.ko" "${merge_fbase}.tok.clean.en" | \
#${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in ko en; do
  outfile=${merge_fbase}.tok.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "${bpe_dir}/bpe32k.koen" < ${merge_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${merge_fbase}.tok.clean.bpe32k.ko" "${merge_fbase}.tok.clean.bpe32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

# Finalizing
mkdir -p tmp
mv ${merge_fbase}.tok.clean.bpe32k.* tmp/
mv vocab.bpe32k tmp/

rm ./*
mv tmp/* ./
rm -r tmp

cp vocab.bpe32k vocab.bpe32k.ko
cp vocab.bpe32k vocab.bpe32k.en

echo "All done."
