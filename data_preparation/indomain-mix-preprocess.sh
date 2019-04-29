set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/home/hkh/data/opensub18-enko
TOKENIZE_SCRIPT=/home/hkh/sources/nmt-ko-en/data_preparation/opensub18-enko.morph.args.sh

cd ${OUTPUT_DIR}

sed -n '200001,400000p' morph.data.tok.400k/train.tok.clean.bpe.16000.en > /tmp/mono200k.train.tok.clean.bpe16k.en
sed -n '200001,400000p' morph.data.tok.400k/train.tok.clean.bpe.16000.ko > /tmp/mono200k.train.tok.clean.bpe16k.ko

sed -n '400001,800000p' morph.data.tok.800k/train.tok.clean.bpe.16000.en > /tmp/mono400k.train.tok.clean.bpe16k.en
sed -n '400001,800000p' morph.data.tok.800k/train.tok.clean.bpe.16000.ko > /tmp/mono400k.train.tok.clean.bpe16k.ko


