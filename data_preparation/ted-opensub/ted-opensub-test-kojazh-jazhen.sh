# Created by hkh at 2018-12-12
# ko, ja, zh(source) -> ja, zh, en (target)
echo "Kwangho's rock! ^_^"

tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013-outdomain/data.kojazh-jazhen
tst_dir=/home/hkh/data/ted2013/tst.en-ko
tst2016=tst2016.en-ko
tst2017=tst2017.en-ko

cp ${tst_dir}/${tst2016}.tok.ko ${data_dir}/
cp ${tst_dir}/${tst2016}.tok.en ${data_dir}/
cp ${tst_dir}/${tst2017}.tok.ko ${data_dir}/
cp ${tst_dir}/${tst2017}.tok.en ${data_dir}/

cd ${data_dir}

# Adding target language tags
echo "Adding target lang tags..."
for file in ${tst2016} ${tst2017}; do
  sed 's/^/<2en> /' ${file}.tok.ko > ${file}.tag.tok.ko
  mv ${file}.tag.tok.ko ${file}.tok.ko
done

# Apply shared BPE
echo "Apply BPE with 50000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in ko en; do
    outfile=${file}.tok.bpe50k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "bpe50k.shared" < "${file}.tok.${lang}" > "${outfile}"
  done
  mv ${file}.tok.bpe50k.ko ${file}.tok.bpe50k.kojazh
  mv ${file}.tok.bpe50k.en ${file}.tok.bpe50k.jazhen
done
echo "All done."
