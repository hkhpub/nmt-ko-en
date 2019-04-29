# Only pre-process without training bpe or truecasing model, use existing models
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

TASK_DIR=/home/hkh/data/opensub18-enko
MAX_SEN_LEN=100

if [ "$#" -lt "2" ] ; then
    # script.sh <morph> <testset_prefix>
    echo 'usage: ./preprocess-enko.train.sh komoran /home/hkh/data/ted-talks-enko/train.notags'
    exit 1
fi
morph=$1
data_dir=data.${morph}
prefix=$2
out_dir=${prefix%/*}
echo "out_dir set to: ${out_dir}"

cd ${TASK_DIR}

echo "Tokenizing $prefix..."
cat ${prefix}.en | \
${TASK_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${prefix}.tok.en

# Morphology analysis for Korean
echo "Morphological processing $prefix..."
cat ${prefix}.ko | \
python ${BASE_DIR}/tools/${morph}_morph.py > ${prefix}.tok.ko


# Train truecaser for English
echo "Truecasing ..."
${TASK_DIR}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus ${prefix}.tok.en

echo "Truecasing $prefix..."
${TASK_DIR}/mosesdecoder/scripts/recaser/truecase.perl --model ${data_dir}/truecase-model.en < ${prefix}.tok.en > ${prefix}.truecase.tok.en
mv ${prefix}.truecase.tok.en ${prefix}.tok.en

echo "Cleaning $prefix..."
${TASK_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl ${prefix}.tok ko en "${prefix}.tok.clean" 1 $MAX_SEN_LEN

# Learning Shared BPE
echo "Learning BPE with merge_ops=32000. This may take a while..."
cat "${prefix}.tok.clean.ko" "${prefix}.tok.clean.en" | \
${TASK_DIR}/subword-nmt/learn_bpe.py -s 32000 -t > "${TASK_DIR}/bpe.32000.shared"

# Apply Shared BPE
echo "Apply BPE with merge_ops=32000 to tokenized files..."
for lang in en ko; do
    for f in ${prefix}.tok.clean.${lang}; do
      outfile="${f%.*}.bpe32k.shared.${lang}"
      ${TASK_DIR}/subword-nmt/apply_bpe.py -c "${TASK_DIR}/${data_dir}/bpe32k.shared" < $f > "${outfile}"
      echo ${outfile}
    done
done; wait

# Create vocabulary file for BPE
cat "${prefix}.tok.clean.bpe.32000.shared.en" "${prefix}.tok.clean.bpe.32000.shared.ko" | \
${TASK_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${out_dir}/vocab.bpe32k.shared"

cp ${out_dir}/vocab.bpe32k.shared ${out_dir}/vocab.bpe32k.shared.en
cp ${out_dir}/vocab.bpe32k.shared ${out_dir}/vocab.bpe32k.shared.ko

mkdir -p ${out_dir}/${data_dir}
echo "Moving files to ${out_dir}/${data_dir}..."
mv ${prefix}.tok.* ${out_dir}/${data_dir}/
mv ${out_dir}/vocab.bpe32k.* ${out_dir}/${data_dir}/
