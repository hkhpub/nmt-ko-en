# Only pre-process without training bpe or truecasing model, use existing models
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

TASK_DIR=/home/hkh/data/opensub18-enko
MAX_SEN_LEN=100

if [ "$#" -lt "2" ] ; then
    # script.sh <morph> <testset_prefix>
    echo 'usage: ./preprocess-enko.test.sh komoran /home/hkh/data/ted-talks-enko/tst2016.en-ko'
    exit 1
fi
morph=$1
data_dir=data.${morph}
prefix=$2
out_dir=${prefix%/.*}
cd ${TASK_DIR}

echo "Tokenizing $prefix..."
cat ${prefix}.en | \
${TASK_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${prefix}.tok.en

# Morphology analysis for Korean
echo "Morphological processing $prefix..."
cat ${prefix}.ko | \
python ${BASE_DIR}/tools/${morph}_morph.py > ${prefix}.tok.ko

echo "Truecasing $prefix..."
${TASK_DIR}/mosesdecoder/scripts/recaser/truecase.perl --model ${data_dir}/truecase-model.en < ${prefix}.tok.en > ${prefix}.truecase.tok.en
mv ${prefix}.truecase.tok.en ${prefix}.tok.en

#echo "Cleaning $prefix.tok ..."
#${TASK_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl ${prefix}.tok ko en "${prefix}.tok.clean" 1 $MAX_SEN_LEN

# Apply Shared BPE
for merge_ops in 16000 32000; do
  echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
  for lang in en ko; do
    for f in ${prefix}.tok.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.shared.${lang}"
      ${TASK_DIR}/subword-nmt/apply_bpe.py -c "${TASK_DIR}/${data_dir}/bpe.${merge_ops}.shared" < $f > "${outfile}"
      echo ${outfile}
    done
  done
done; wait

# Apply Independent BPE for each language
for merge_ops in 16000 32000; do
 echo "Apply BPE with merge_ops=${merge_ops}.${lang} to tokenized files..."
 for lang in en ko; do
    for f in ${prefix}.tok.${lang}; do
      outfile="${f%.*}.bpe.${merge_ops}.${lang}"
      ${TASK_DIR}/subword-nmt/apply_bpe.py -c "${TASK_DIR}/${data_dir}/bpe.${merge_ops}.${lang}" < $f > "${outfile}"
      echo ${outfile}
    done
  done
done; wait

echo "Moving ${prefix}.tok.* to ${data_dir}..."
mv ${prefix}.tok.* ${data_dir}/