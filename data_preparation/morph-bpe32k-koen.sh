if [ "$#" -eq "0" ] ; then
    echo 'usage: ./morph-bpe32k-koen.sh data.mecab'
    exit 1
fi

cd /home/hkh/data/opensub18-enko/$1

cp vocab.morph.ko vocab.morph-bpe32k.ko
cp vocab.bpe.32000.en vocab.morph-bpe32k.en

cp train.tok.clean.bpe.32000.en train.tok.clean.morph-bpe32k.en
cp dev.tok.clean.bpe.32000.en dev.tok.clean.morph-bpe32k.en
cp test.tok.clean.bpe.32000.en test.tok.clean.morph-bpe32k.en

cp train.tok.clean.ko train.tok.clean.morph-bpe32k.ko
cp dev.tok.clean.ko dev.tok.clean.morph-bpe32k.ko
cp test.tok.clean.ko test.tok.clean.morph-bpe32k.ko
