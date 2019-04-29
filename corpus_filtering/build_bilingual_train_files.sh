# Created by hkh at 2019-03-21
data_dir=/home/hkh/data/ted2013/data.ko-en
out_dir=/home/hkh/data/ted2013/data.bilingual.ko-en
koen_fbase=train.ko-en

mkdir -p ${out_dir}

# source file
cat $data_dir/$koen_fbase.tok.clean.bpe32k.ko $data_dir/$koen_fbase.tok.clean.bpe32k.en \
> $out_dir/$koen_fbase.bilingual.tok.clean.bpe32k.src

# target file
cat $data_dir/$koen_fbase.tok.clean.bpe32k.en $data_dir/$koen_fbase.tok.clean.bpe32k.ko \
> $out_dir/$koen_fbase.bilingual.tok.clean.bpe32k.tgt

echo "Done!"
