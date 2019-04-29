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

# Morphology analysis for Korean
for file in train dev test; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.ko | \
  python ${BASE_DIR}/tools/replace_space.py | \
  python ${BASE_DIR}/tools/mecab_postag.py > ${file}.tok.ko &
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

# Create vocabulary (on tokenized data)
${BASE_DIR}/tools/generate_vocab.py \
  --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.en \
  > ${OUTPUT_DIR}/vocab.pos.en
${BASE_DIR}/tools/generate_vocab.py \
  --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.ko \
  > ${OUTPUT_DIR}/vocab.pos.ko

# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${OUTPUT_DIR}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${OUTPUT_DIR}/subword-nmt"
fi

# Learn Shared BPE
for merge_ops in 16000 32000; do
  echo "Learning BPE with merge_ops=${merge_ops}. This may take a while..."
  cat "${OUTPUT_DIR}/train.tok.clean.ko" "${OUTPUT_DIR}/train.tok.clean.en" | \
    ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops > "${OUTPUT_DIR}/bpe.${merge_ops}"

  echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
  for lang in en ko; do
    for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.${lang}"
      ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}" < $f > "${outfile}"
      echo ${outfile}
    done
  done

  # Create vocabulary file for BPE
  cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.ko" | \
    ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}"

done

cp vocab.bpe.16000 vocab.bpe.16000.en
cp vocab.bpe.16000 vocab.bpe.16000.ko
cp vocab.bpe.32000 vocab.bpe.32000.en
cp vocab.bpe.32000 vocab.bpe.32000.ko

mkdir -p ${OUTPUT_DIR}/data.pos
mv train.* dev.* test.* vocab.* bpe.* ${OUTPUT_DIR}/data.pos

echo "All done."
