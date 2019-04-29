# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/tst2016.en-ko.[en|ko]
#           /home/hkh/data/ted2013/tst2017.en-ko.[en|ko]
MAX_SEN_LEN=50
tools_dir=/home/hkh/tools

copy_data_dir=/home/hkh/data/ted2013/data.ko-en
data_dir=/home/hkh/data/ted2013/data.ste.ko-en
tst2016=tst2016.en-ko
tst2017=tst2017.en-ko

mkdir -p ${data_dir}
cd ${data_dir}

echo "Copy files..."
for file in ${tst2016} ${tst2017}; do
  cp ${copy_data_dir}/${file}.tok.ko ${data_dir}/
  cp ${copy_data_dir}/${file}.tok.en ${data_dir}/
done

# Apply shared BPE
echo "Apply STE with 32000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in ko en; do
    outfile=${file}.tok.ste32k.${lang}
    python ${tools_dir}/ste_tokenizer/encode_ste.py "vocab.ste32k.shared" < ${file}.tok.${lang} > "${outfile}"
  done
done
echo "All done."