# Created by hkh at 2018-12-12

tools_dir=/home/hkh/tools
data_dir=/home/hkh/data

# tokenize English
echo "Tokenizing English..."
for file in ${data_dir}/opensub18/opensub.en-ko \
            ${data_dir}/opensub18/opensub.en-zh \
            ${data_dir}/opensub18/opensub.en-ja \
            ${data_dir}/multiun/multiun.en-zh \
            ${data_dir}/tanzil/tanzil.en-zh \
            ${data_dir}/tatoeba/tatoeba.en-ja \
            ${data_dir}/ted2013/ko-en/train.ko-en \
            ${data_dir}/ted2013/ja-en/train.ja-en \
            ${data_dir}/ted2013/zh-en/train.zh-en; do
  ${tools_dir}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 < ${file}.en > ${file}.tok.en &
done; wait

# tokenize Korean
echo "Tokenizing Korean..."
for file in ${data_dir}/opensub18/opensub.en-ko \
            ${data_dir}/opensub18/opensub.ja-ko \
            ${data_dir}/opensub18/opensub.ko-zh \
            ${data_dir}/ted2013/ko-en/train.ko-en \
            ${data_dir}/ted2013/ko-ja/train.ko-ja \
            ${data_dir}/ted2013/ko-zh/train.ko-zh; do
  python ${tools_dir}/komoran_morph.py < ${file}.ko > ${file}.tok.ko &
done; wait

# tokenize Chinese
echo "Tokenizing Chinese..."
for file in ${data_dir}/opensub18/opensub.ko-zh \
            ${data_dir}/opensub18/opensub.en-zh \
            ${data_dir}/multiun/multiun.en-zh \
            ${data_dir}/tanzil/tanzil.en-zh \
            ${data_dir}/ted2013/zh-en/train.zh-en \
            ${data_dir}/ted2013/ko-zh/train.ko-zh; do
  ${tools_dir}/stanford-segmenter/segment.sh -3 ctb ${file}.zh UTF8 0 > ${file}.tok.zh &
done; wait

# tokenize Japanese
echo "Tokenizing Japanese..."
for file in ${data_dir}/opensub18/opensub.en-ja \
            ${data_dir}/opensub18/opensub.ja-ko \
            ${data_dir}/tatoeba/tatoeba.en-ja \
            ${data_dir}/ted2013/ja-en/train.ja-en \
            ${data_dir}/ted2013/ko-ja/train.ko-ja; do
  mecab ${file}.ja -O wakati > ${file}.tok.ja &
done; wait
