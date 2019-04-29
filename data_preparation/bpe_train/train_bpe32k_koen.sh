# Created by hkh at 2019-03-13
tools_dir=/home/hkh/tools
data_dir=/home/hkh/data/bpe32k-koen

cd ${data_dir}
echo "" > train_file

# train bpe32k
echo "merging file"
for file in `ls $data_dir`; do
  cat $file >> train_file
done

echo "total `wc -l train_file`"
cat train_file | ${tools_dir}/subword-nmt/learn_bpe.py -s 32000 -t > "bpe32k.koen"

echo "Done!"
