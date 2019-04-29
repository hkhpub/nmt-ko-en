# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ko-ja/train.ko-ja.[ko|ja]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
echo "Kwangho's rock! ^_^"

MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.koja-jaen
koen_dir=/home/hkh/data/ted2013/ko-en
koja_dir=/home/hkh/data/ted2013/ko-ja
jaen_dir=/home/hkh/data/ted2013/ja-en

koen_fbase=train.ko-en
koja_fbase=train.ko-ja
jaen_fbase=train.ja-en

mkdir -p ${data_dir}
cp ${koen_dir}/${koen_fbase}.* ${data_dir}/
cp ${koja_dir}/${koja_fbase}.* ${data_dir}/
cp ${jaen_dir}/${jaen_fbase}.* ${data_dir}/

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

# Tokenize Korean data
echo "Tokenizing Korean ${koen_fbase}.ko"
python ${tools_dir}/komoran_morph.py < ${koen_fbase}.ko > ${koen_fbase}.tok.ko
python ${tools_dir}/komoran_morph.py < ${koja_fbase}.ko > ${koja_fbase}.tok.ko

# Tokenize Japanese data
echo "Tokenizing Japanses ${jaen_fbase}.ja"
mecab ${koja_fbase}.ja -O wakati > ${koja_fbase}.tok.ja
mecab ${jaen_fbase}.ja -O wakati > ${jaen_fbase}.tok.ja

# Tokenize English data
echo "Tokenizing English ${koen_fbase}.en"
cat ${koen_fbase}.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${koen_fbase}.tok.en &

echo "Tokenizing English ${jaen_fbase}.en"
cat ${jaen_fbase}.en | \
${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${jaen_fbase}.tok.en &
wait

# Truecase English data
echo "Truecasing English data..."
cat ${koen_fbase}.tok.en ${jaen_fbase}.tok.en > "corpus.tok.en"
${tools_dir}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus corpus.tok.en
for file in ${koen_fbase} ${jaen_fbase}; do
  ${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.truecase.tok.en
  mv ${file}.truecase.tok.en ${file}.tok.en
done

# Adding target language tags
echo "Adding target lang tags..."
sed 's/^/<2en> /' ${koen_fbase}.tok.ko > ${koen_fbase}.tag.tok.ko
sed 's/^/<2ja> /' ${koja_fbase}.tok.ko > ${koja_fbase}.tag.tok.ko
sed 's/^/<2en> /' ${jaen_fbase}.tok.ja > ${jaen_fbase}.tag.tok.ja
mv ${koen_fbase}.tag.tok.ko ${koen_fbase}.tok.ko
mv ${koja_fbase}.tag.tok.ko ${koja_fbase}.tok.ko
mv ${jaen_fbase}.tag.tok.ja ${jaen_fbase}.tok.ja

echo "Merging data files..."
merge_fbase=train.merge
cat ${koen_fbase}.tok.ko ${koja_fbase}.tok.ko ${jaen_fbase}.tok.ja > "${merge_fbase}.tok.koja"
cat ${koen_fbase}.tok.en ${koja_fbase}.tok.ja ${jaen_fbase}.tok.en > "${merge_fbase}.tok.jaen"

# Clean all corpora
echo "Cleaning corpora..."
${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${merge_fbase}.tok "koja" "jaen" "${merge_fbase}.tok.clean" 1 $MAX_SEN_LEN

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

cp vocab.bpe32k vocab.bpe32k.koja
cp vocab.bpe32k vocab.bpe32k.jaen

echo "All done."