# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]

TOOLS_DIR=/home/hkh/tools

koen_dir=/home/hkh/data/ted2013/ko-en
jaen_dir=/home/hkh/data/ted2013/ja-en

# Clone Moses
if [ ! -d "${TOOLS_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${TOOLS_DIR}/mosesdecoder"
fi

# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${TOOLS_DIR}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${TOOLS_DIR}/subword-nmt"
fi
