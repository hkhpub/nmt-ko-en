set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/home/hkh/data/opensub18-enko
MAX_SEN_LEN=50

cd ${OUTPUT_DIR}

cp ${OUTPUT_DIR}/corpus.org/train.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/corpus.org/dev.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/corpus.org/test.* ${OUTPUT_DIR}/

# Clone Moses
if [ ! -d "${OUTPUT_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${OUTPUT_DIR}/mosesdecoder"
fi

# Tokenize English data
for file in train dev test; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.en | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${file}.tok.en &
done; wait

# Tokenize Korean data
for file in train dev test; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.ko | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${file}.tok.ko &
done; wait

# Train truecaser for English
echo "Truecasing ..."
cat train.tok.en dev.tok.en > train_dev.tok.en
${OUTPUT_DIR}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus train_dev.tok.en

# Truecase English data
for file in train dev; do
    ${OUTPUT_DIR}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.truecase.tok.en &
    mv ${file}.truecase.tok.en ${file}.tok.en
done; wait
rm train_dev.tok.en

# Clean all corpora
for file in ${OUTPUT_DIR}/*.tok.en; do
  fbase=${file%.*}
  echo "Cleaning ${fbase}..."
  ${OUTPUT_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl $fbase ko en "${fbase}.clean" 1 $MAX_SEN_LEN
done; wait

# Char unit encoding
for file in train dev test; do
  echo "Char encoding $file..."
  ${OUTPUT_DIR}/scripts/make_char_sequence.py < ${file}.tok.clean.en > ${file}.tok.clean.char.en &
  ${OUTPUT_DIR}/scripts/make_char_sequence.py < ${file}.tok.clean.ko > ${file}.tok.clean.char.ko &
done; wait

# Create character vocabulary (on tokenized data)
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.char.en \
  > ${OUTPUT_DIR}/vocab.char.en
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.char.ko \
  > ${OUTPUT_DIR}/vocab.char.ko


mkdir -p ${OUTPUT_DIR}/data.char
mv train.* dev.* test.* vocab.* bpe.* ${OUTPUT_DIR}/data.char

echo "All done."
