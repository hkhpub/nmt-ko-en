set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

OUTPUT_DIR=/home/hkh/data/opensub18-enko
TOKENIZE_SCRIPT=/home/hkh/sources/nmt-ko-en/data_preparation/opensub18-enko.morph.args.sh

cd ${OUTPUT_DIR}

sed -n '1,200000p' /home/hkh/data/wmt16_en_data/train.tok.clean.en > /tmp/wmt_200k.tok.clean.en
sed -n '1,200000p' /home/hkh/data/wmt16_en_data/synthetic.200k.train.1m.tok.clean.ko > /tmp/wmt_200k.tok.clean.ko

sed -n '1,400000p' /home/hkh/data/wmt16_en_data/train.tok.clean.en > /tmp/wmt_400k.tok.clean.en
sed -n '1,400000p' /home/hkh/data/wmt16_en_data/synthetic.400k.train.1m.tok.clean.ko > /tmp/wmt_400k.tok.clean.ko

for name in 200k 400k; do
    mkdir -p mix.corpus.morph.${name}
    mkdir -p morph.mix.data.tok.${name}

    cp corpus.morph.${name}/dev.en mix.corpus.morph.${name}/dev.en
    cp corpus.morph.${name}/dev.ko mix.corpus.morph.${name}/dev.ko
    cp corpus.morph.${name}/test.en mix.corpus.morph.${name}/test.en
    cp corpus.morph.${name}/test.ko mix.corpus.morph.${name}/test.ko

    cat corpus.morph.${name}/train.en /tmp/wmt_${name}.tok.clean.en > mix.corpus.morph.${name}/train.en
    cat corpus.morph.${name}/train.ko /tmp/wmt_${name}.tok.clean.ko > mix.corpus.morph.${name}/train.ko

    echo 'Processing directory ->' ${name}
    ( exec ${TOKENIZE_SCRIPT} mix.corpus.morph.${name} morph.mix.data.tok.${name} ) &
    wait
done; wait
