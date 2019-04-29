# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
data_dir=/home/hkh/data/ted2013/data.spm.ko-en
koen_dir=/home/hkh/data/ted2013/ko-en
koen_fbase=train.ko-en

#mkdir -p ${data_dir}
#cp ${koen_dir}/${koen_fbase}.* ${data_dir}/

cd ${data_dir}

# Clone Moses
if [ ! -d "${tools_dir}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${tools_dir}/mosesdecoder"
fi

# Generate Subword Units (BPE)
# Clone Subword NMT
if [ ! -d "${tools_dir}/subword-nmt" ]; then
  git clone https://github.com/rsennrich/subword-nmt.git "${tools_dir}/subword-nmt"
fi

## Tokenize Korean data
#echo "Tokenizing Korean ${koen_fbase}.ko"
#python ${tools_dir}/komoran_morph.py < ${koen_fbase}.ko > ${koen_fbase}.tok.ko
#
## Tokenize English data
#echo "Tokenizing English ${koen_fbase}.en"
#cat ${koen_fbase}.en | \
#${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 > ${koen_fbase}.tok.en &
#wait
#
## Truecase English data
#echo "Truecasing English data..."
#${tools_dir}/mosesdecoder/scripts/recaser/train-truecaser.perl --model truecase-model.en --corpus ${koen_fbase}.tok.en
#${tools_dir}/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < ${koen_fbase}.tok.en > ${koen_fbase}.truecase.tok.en
#mv ${koen_fbase}.truecase.tok.en ${koen_fbase}.tok.en
#
### Clean all corpora
#echo "Cleaning corpora..."
#${tools_dir}/mosesdecoder/scripts/training/clean-corpus-n.perl ${koen_fbase}.tok ko en "${koen_fbase}.tok.clean" 1 $MAX_SEN_LEN

# Learn Shared sentencepiece model
echo "Learning SPM with 32000. This may take a while..."
cat "${koen_fbase}.tok.clean.ko" "${koen_fbase}.tok.clean.en" > spm.train
spm_train --input=spm.train --model_prefix=spm32k.shared --vocab_size=32000 --model_type=unigram
rm spm.train

echo "Apply SPM with 32000 to tokenized files..."
for lang in ko en; do
  outfile=${koen_fbase}.tok.clean.spm32k.${lang}
  spm_encode --model=spm32k.shared.model < ${koen_fbase}.tok.clean.${lang} > "${outfile}"
done

# Create vocabulary file for SPM
cat "${koen_fbase}.tok.clean.spm32k.ko" "${koen_fbase}.tok.clean.spm32k.en" | \
${tools_dir}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > vocab.spm32k

cp vocab.spm32k vocab.spm32k.ko
cp vocab.spm32k vocab.spm32k.en

echo "All done."
