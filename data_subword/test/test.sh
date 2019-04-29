# Created by hkh at 2019-03-08
base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
file=tst2016.en-ko
cat "${file}.en" | \
python learn_ste.py "vocab.ste32k.shared"

for lang in ko en; do
  outfile=${file}.ste32k.${lang}
  python encode_ste.py "vocab.ste32k.shared" < ${file}.${lang} > "${outfile}"
done
