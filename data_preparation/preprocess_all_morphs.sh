TOKENIZE_SCRIPT=/home/hkh/sources/nmt-ko-en/data_preparation/opensub18-enko.morph.args.sh

# for morph in komoran kkma twitter mecab; do
for morph in mecab; do
    echo 'Processing morph ->' ${morph}
    ( exec ${TOKENIZE_SCRIPT} ${morph} ) &
    wait
done; wait