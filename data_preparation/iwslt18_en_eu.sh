set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/hdd/data/iwslt18
MAX_SEN_LEN=50

cd ${OUTPUT_DIR}

mkdir -p ${OUTPUT_DIR}/corpus.org
cp ${OUTPUT_DIR}/data.raw/train/train.raw.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/data.raw/dev/dev.raw.* ${OUTPUT_DIR}/

# Clone Moses
if [ ! -d "${OUTPUT_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${OUTPUT_DIR}/mosesdecoder"
fi

# Tokenize English data
for file in train dev; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.raw.en | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l de -threads 8 > ${file}.tok.en &
done; wait

# Tokenize Basque data
for file in train dev; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.raw.eu | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l de -threads 8 > ${file}.tok.eu &
done; wait

## Train truecaser for English
#cat train.tok.en dev.tok.en > train_dev.tok.en
#${OUTPUT_DIR}/mosesdecoder/recaser/train-truecaser.perl --model truecase-model.en --corpus train_dev.tok.en
#
## Truecase English data
#for file in train dev; do
#    ${OUTPUT_DIR}/mosesdecoder/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.en &
#done; wait

# Clean all corpora
for file in ${OUTPUT_DIR}/*.tok.en; do
  fbase=${file%.*}
  echo "Cleaning ${fbase}..."
  ${OUTPUT_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl $fbase eu en "${fbase}.clean" 1 $MAX_SEN_LEN
done

# Create character vocabulary (on tokenized data)
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.en \
  > ${OUTPUT_DIR}/vocab.tok.char.en
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.eu \
  > ${OUTPUT_DIR}/vocab.tok.char.eu

# Create character vocabulary (on non-tokenized data)
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.raw.en \
  > ${OUTPUT_DIR}/vocab.char.en
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.raw.eu \
  > ${OUTPUT_DIR}/vocab.char.eu

# Create vocabulary for EN data
${BASE_DIR}/tools/generate_vocab.py \
   --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.en \
  > ${OUTPUT_DIR}/vocab.50k.en \

# Create vocabulary for Basque data
${BASE_DIR}/tools/generate_vocab.py \
  --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.eu \
  > ${OUTPUT_DIR}/vocab.50k.eu \


# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${OUTPUT_DIR}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${OUTPUT_DIR}/subword-nmt"
fi

# Learn Shared BPE
for merge_ops in 16000; do
  echo "Learning BPE with merge_ops=${merge_ops}. This may take a while..."
  cat "${OUTPUT_DIR}/train.tok.clean.eu" "${OUTPUT_DIR}/train.tok.clean.en" | \
    ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops > "${OUTPUT_DIR}/bpe.${merge_ops}"

  echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
  for lang in en eu; do
    for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.${lang}"
      ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}" < $f > "${outfile}"
      echo ${outfile}
    done
  done

  # Create vocabulary file for BPE
  cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.eu" | \
    ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}"

done

mkdir -p ${OUTPUT_DIR}/data.tok
mv train.* dev.* vocab.* bpe.* ${OUTPUT_DIR}/data.tok

echo "All done."
