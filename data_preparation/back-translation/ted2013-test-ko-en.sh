# Created by hkh at 2018-12-07
# ko, ja (source) -> en (target)
# data_dir: /home/hkh/data/ted2013/tst2016.en-ko.[en|ko]
#           /home/hkh/data/ted2013/tst2017.en-ko.[en|ko]
echo "Kwangho's rock! ^_^"

tools_dir=/home/hkh/tools

data_dir=/home/hkh/data/ted2013/data.bpe.ko-en
org_dir=/home/hkh/data/ted2013/data.ko-en
bpe_dir=/home/hkh/data/bpe-koen

tst2016=tst2016.en-ko
tst2017=tst2017.en-ko

mkdir -p ${data_dir}
cp ${org_dir}/${tst2016}.* ${data_dir}/
cp ${org_dir}/${tst2017}.* ${data_dir}/

cd ${data_dir}

# Apply shared BPE
echo "Apply BPE with 32000 to tokenized files..."
for file in ${tst2016} ${tst2017}; do
  for lang in ko en; do
    outfile=${file}.tok.bpe32k.${lang}
    ${tools_dir}/subword-nmt/apply_bpe.py -c "${bpe_dir}/bpe32k.koen" < ${file}.tok.${lang} > "${outfile}"
  done
done
echo "All done."
