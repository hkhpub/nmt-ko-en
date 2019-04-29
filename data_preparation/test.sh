set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

DATA_DIR=${1}
OUTPUT_DATA_DIR=${2}
OUTPUT_DIR=/home/hkh/data/opensub18-enko
MAX_SEN_LEN=50

cd ${OUTPUT_DIR}

ls ${OUTPUT_DIR}/${DATA_DIR}/train.*
echo ${OUTPUT_DIR}/${OUTPUT_DATA_DIR}
