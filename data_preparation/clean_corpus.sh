OUTPUT_DIR=/home/hkh/data/iwslt18/open-subtitles
DATA_DIR=${OUTPUT_DIR}/mix.1to1.out-domain
MAX_SEN_LEN=50

# Clone Moses
if [ ! -d "${OUTPUT_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${OUTPUT_DIR}/mosesdecoder"
fi

# Clean all corpora
for file in ${DATA_DIR}/*train; do
  fbase=${file%.*}
  echo "Cleaning ${fbase}..."
  ${OUTPUT_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl $fbase eu en "${fbase}.clean" 1 $MAX_SEN_LEN
done; wait

