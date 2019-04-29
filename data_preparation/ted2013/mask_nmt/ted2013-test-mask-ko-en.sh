# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/ko-en/train.ko-en.[ko|en]
#           /home/hkh/data/ted2013/ja-en/train.ja-en.[ja|en]
echo "Kwangho's rock! ^_^"

MAX_SEN_LEN=50
tools_dir=/home/hkh/tools
base_dir=/home/hkh/sources/nmt-ko-en

data_dir=/home/hkh/data/ted2013/data.mask.ko-en
tst2016=tst2016.en-ko
tst2017=tst2017.en-ko

cd ${data_dir}

# pos tagging & masking
echo "Pos tagging & masking..."
for file in ${tst2016} ${tst2017}; do
  python ${base_dir}/tools/english_postagger.py < "${file}.tok.en" > "${file}.tag.en"
  python ${base_dir}/tools/komoran_tag_morph.py < "${file}.ko" > "${file}.tag.ko"
  python ${base_dir}/tools/masking/english_masking.py < "${file}.tag.en" > "${file}.mask.en"
  python ${base_dir}/tools/masking/korean_masking.py < "${file}.tag.ko" > "${file}.mask.ko"
done

# Apply shared BPE
echo "Apply BPE with 32000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in ko en; do
    outfile=${file}.mask.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe32k.mask.shared" < ${file}.mask.${lang} > "${outfile}"
  done
done
echo "All done."
