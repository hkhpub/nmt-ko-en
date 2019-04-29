# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Kkma
kkma = Kkma()

for line in sys.stdin:
    try:
        line = line.strip()
        print(" ".join(kkma.morphs(line)))
    except:
        print("error: <", line, ">")
