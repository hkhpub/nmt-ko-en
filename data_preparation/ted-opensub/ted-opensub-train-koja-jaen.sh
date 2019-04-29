# Created by hkh at 2018-12-11
# ko, ja (source) -> ja, en (target)
echo "Kwangho's rock! ^_^"

MIN_SEN_LEN=3
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013-outdomain/data.koja-jaen
opensub_dir=/home/hkh/data/opensub18
ted_dir=/home/hkh/data/ted2013/train.all
tatoeba_dir=/home/hkh/data/tatoeba

opensub_koen_fbase=opensub.en-ko
opensub_koja_fbase=opensub.ja-ko
opensub_jaen_fbase=opensub.en-ja
ted_koen_fbase=train.ko-en
ted_koja_fbase=train.ko-ja
ted_jaen_fbase=train.ja-en
tatoeba_jaen_fbase=tatoeba.en-ja

mkdir -p ${data_dir}

# copy data
cp ${opensub_dir}/${opensub_koen_fbase}.tok.* ${data_dir}/
cp ${opensub_dir}/${opensub_koja_fbase}.tok.* ${data_dir}/
cp ${opensub_dir}/${opensub_jaen_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_koen_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_koja_fbase}.tok.* ${data_dir}/
cp ${ted_dir}/${ted_jaen_fbase}.tok.* ${data_dir}/
cp ${tatoeba_dir}/${tatoeba_jaen_fbase}.tok.* ${data_dir}/

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
sed 's/^/<2ja> /' ${opensub_koja_fbase}.tok.ko > ${opensub_koja_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${opensub_jaen_fbase}.tok.ja > ${opensub_jaen_fbase}.tag.tok.ja
sed 's/^/<2en> /' ${ted_koen_fbase}.tok.ko > ${ted_koen_fbase}.tag.tok.ko
sed 's/^/<2ja> /' ${ted_koja_fbase}.tok.ko > ${ted_koja_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${ted_jaen_fbase}.tok.ja > ${ted_jaen_fbase}.tag.tok.ja
sed 's/^/<2en> /' ${tatoeba_jaen_fbase}.tok.ja > ${tatoeba_jaen_fbase}.tag.tok.ja
mv ${opensub_koen_fbase}.tag.tok.ko ${opensub_koen_fbase}.tok.ko
mv ${opensub_koja_fbase}.tag.tok.ko ${opensub_koja_fbase}.tok.ko
mv ${opensub_jaen_fbase}.tag.tok.ja ${opensub_jaen_fbase}.tok.ja
mv ${ted_koen_fbase}.tag.tok.ko ${ted_koen_fbase}.tok.ko
mv ${ted_koja_fbase}.tag.tok.ko ${ted_koja_fbase}.tok.ko
mv ${ted_jaen_fbase}.tag.tok.ja ${ted_jaen_fbase}.tok.ja
mv ${tatoeba_jaen_fbase}.tag.tok.ja ${tatoeba_jaen_fbase}.tok.ja

echo "Merging data files..."
merge_fbase=train.merge
# merging source side resources
cat ${opensub_koen_fbase}.tok.ko \
    ${opensub_koja_fbase}.tok.ko \
    ${opensub_jaen_fbase}.tok.ja \
    ${ted_koen_fbase}.tok.ko \
    ${ted_koja_fbase}.tok.ko \
    ${ted_jaen_fbase}.tok.ja \
    ${tatoeba_jaen_fbase}.tok.ja > "${merge_fbase}.tok.koja"

# merging target side resources
cat ${opensub_koen_fbase}.tok.en \
    ${opensub_koja_fbase}.tok.ja \
    ${opensub_jaen_fbase}.tok.en \
    ${ted_koen_fbase}.tok.en \
    ${ted_koja_fbase}.tok.ja \
    ${ted_jaen_fbase}.tok.en \
    ${tatoeba_jaen_fbase}.tok.en > "${merge_fbase}.tok.jaen"

## Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${merge_fbase}.tok koja jaen "${merge_fbase}.tok.clean" $MIN_SEN_LEN $MAX_SEN_LEN

# Learn Shared BPE
echo "Learning BPE with 32000. This may take a while..."
cat "${merge_fbase}.tok.clean.koja" "${merge_fbase}.tok.clean.jaen" | \
${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.shared"

echo "Apply BPE with 32000 to tokenized files..."
for lang in koja jaen; do
  outfile=${merge_fbase}.tok.clean.bpe32k.${lang}
  ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.shared" < ${merge_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for BPE
cat "${merge_fbase}.tok.clean.bpe32k.koja" "${merge_fbase}.tok.clean.bpe32k.jaen" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.bpe32k

# Finalizing
mkdir -p tmp
mv ${merge_fbase}.tok.clean.bpe32k.* tmp/
mv vocab.bpe32k tmp/
mv bpe32k.shared tmp/

rm ./*
mv tmp/* ./
rm -r tmp

cp vocab.bpe32k vocab.bpe32k.koja
cp vocab.bpe32k vocab.bpe32k.jaen

echo "All done."