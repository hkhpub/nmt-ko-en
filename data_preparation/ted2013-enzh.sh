set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/home/hkh/data/ted2013-enzh
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
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l de -threads 8 > ${file}.tok.en &
done; wait

# Tokenize Basque data
for file in train dev test; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.zh | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l de -threads 8 > ${file}.tok.zh &
done; wait

# Train truecaser for English
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
  ${OUTPUT_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl $fbase zh en "${fbase}.clean" 1 $MAX_SEN_LEN
done; wait

# Create character vocabulary (on tokenized data)
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.en \
  > ${OUTPUT_DIR}/vocab.tok.char.en
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.tok.clean.zh \
  > ${OUTPUT_DIR}/vocab.tok.char.zh

# Create character vocabulary (on non-tokenized data)
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.en \
  > ${OUTPUT_DIR}/vocab.char.en
${BASE_DIR}/tools/generate_vocab.py --delimiter "" \
  < ${OUTPUT_DIR}/train.zh \
  > ${OUTPUT_DIR}/vocab.char.zh

# Create vocabulary for EN data
${BASE_DIR}/tools/generate_vocab.py \
   --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.en \
  > ${OUTPUT_DIR}/vocab.50k.en \

# Create vocabulary for Basque data
${BASE_DIR}/tools/generate_vocab.py \
  --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.zh \
  > ${OUTPUT_DIR}/vocab.50k.zh \


# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${OUTPUT_DIR}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${OUTPUT_DIR}/subword-nmt"
fi

# Learn Shared BPE
for merge_ops in 16000 32000; do
  echo "Learning BPE with merge_ops=${merge_ops}. This may take a while..."
  cat "${OUTPUT_DIR}/train.tok.clean.zh" "${OUTPUT_DIR}/train.tok.clean.en" | \
    ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops > "${OUTPUT_DIR}/bpe.${merge_ops}"

  echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
  for lang in en zh; do
    for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.${lang}"
      ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}" < $f > "${outfile}"
      echo ${outfile}
    done
  done

  # Create vocabulary file for BPE
  cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.zh" | \
    ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}"

done

cp vocab.bpe.16000 vocab.bpe.16000.en
cp vocab.bpe.16000 vocab.bpe.16000.zh
cp vocab.bpe.32000 vocab.bpe.32000.en
cp vocab.bpe.32000 vocab.bpe.32000.zh

mkdir -p ${OUTPUT_DIR}/data.tok
mv train.* dev.* test.* vocab.* bpe.* ${OUTPUT_DIR}/data.tok

echo "All done."
