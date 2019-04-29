# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Mecab
SPACE_SYMBOL = "▁"

mecab = Mecab()

for line in sys.stdin:
    line = line.strip()
    print((" %s " % SPACE_SYMBOL).join(line.split()))