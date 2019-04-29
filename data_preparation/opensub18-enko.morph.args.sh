set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/home/hkh/data/opensub18-enko
MAX_SEN_LEN=50

if [ "$#" -eq "0" ] ; then
    echo 'usage: ./opensub18-enko.morph.args.sh komoran'
    exit 1
fi
morph=$1
echo ${morph}

cd ${OUTPUT_DIR}

cp ${OUTPUT_DIR}/corpus.back/train.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/corpus.back/dev.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/corpus.back/test.* ${OUTPUT_DIR}/
cp ${OUTPUT_DIR}/corpus.back/mono.* ${OUTPUT_DIR}/

# Clone Moses
if [ ! -d "${OUTPUT_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${OUTPUT_DIR}/mosesdecoder"
fi

# Tokenize English data
for file in train dev test mono; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.en | \
  ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${file}.tok.en &
done; wait

# Morphology analysis for Korean
for file in train dev test mono; do
  echo "Tokenizing $file..."
  cat ${OUTPUT_DIR}/${file}.ko | \
  python ${BASE_DIR}/tools/${morph}_morph.py > ${file}.tok.ko &
done; wait

# Train truecaser for English
echo "Truecasing ..."
cat train.tok.en dev.tok.en > train_dev.tok.en
${OUTPUT_DIR}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus train_dev.tok.en

# Truecase English data
for file in train dev test mono; do
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
  > ${OUTPUT_DIR}/vocab.morph.en
${BASE_DIR}/tools/generate_vocab.py \
  --max_vocab_size 50000 \
  < ${OUTPUT_DIR}/train.tok.clean.ko \
  > ${OUTPUT_DIR}/vocab.morph.ko


# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${OUTPUT_DIR}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${OUTPUT_DIR}/subword-nmt"
fi

# Learn Shared BPE
for merge_ops in 16000 32000; do
  echo "Learning BPE with merge_ops=${merge_ops}. This may take a while..."
  cat "${OUTPUT_DIR}/train.tok.clean.ko" "${OUTPUT_DIR}/train.tok.clean.en" | \
    ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops -t > "${OUTPUT_DIR}/bpe.${merge_ops}.shared"

  echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
  for lang in en ko; do
    for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.shared.${lang}"
      ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}.shared" < $f > "${outfile}"
      echo ${outfile}
    done
  done

  # Create vocabulary file for BPE
  cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.shared.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.shared.ko" | \
    ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}.shared"

done

# Learn Independent BPE for each language
for merge_ops in 16000 32000; do

  for lang in en ko; do
    echo "Learning BPE with merge_ops=${merge_ops}.${lang} This may take a while..."
    cat "${OUTPUT_DIR}/train.tok.clean.${lang}" | \
    ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops -t > "${OUTPUT_DIR}/bpe.${merge_ops}.${lang}"

    echo "Apply BPE with merge_ops=${merge_ops}.${lang} to tokenized files..."
    for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.${lang}"
      ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}.${lang}" < $f > "${outfile}"
      echo ${outfile}
    done

    # Create vocabulary file for BPE
    cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.${lang}" | \
    ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}.${lang}"
  done
done

cp vocab.bpe.16000.shared vocab.bpe.16000.shared.en
cp vocab.bpe.16000.shared vocab.bpe.16000.shared.ko
cp vocab.bpe.32000.shared vocab.bpe.32000.shared.en
cp vocab.bpe.32000.shared vocab.bpe.32000.shared.ko

mkdir -p ${OUTPUT_DIR}/data.${morph}
mv train.* dev.* test.* mono.* vocab.* bpe.* ${OUTPUT_DIR}/data.${morph}
cp truecase-model.en ${OUTPUT_DIR}/data.${morph}

echo "All done."
