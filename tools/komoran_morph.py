# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Komoran
komoran = Komoran()

for line in sys.stdin:
    try:
        line = line.strip()
        print(" ".join(komoran.morphs(line)))
    except:
        print("error: <", line, ">")
