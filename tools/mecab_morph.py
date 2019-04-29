# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Mecab
mecab = Mecab()

for line in sys.stdin:
    line = line.strip()
    print(" ".join(mecab.morphs(line)))
