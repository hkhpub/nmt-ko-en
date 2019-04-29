# Created by hkh at 2019-03-08
base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
file=tst2016.en-ko.tok
cat "${file}.en" | \
python ${base_dir}/ste_tokenizer/learn_ste_tf.py "vocab.ste32k.shared"

for lang in ko en; do
  outfile=${file}.ste32k.${lang}
  python ${base_dir}/ste_tokenizer/encode_ste_tf.py "vocab.ste32k.shared" < ${file}.${lang} > "${outfile}"
done
