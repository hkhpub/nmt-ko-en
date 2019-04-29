# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Komoran
komoran = Komoran()

for line in sys.stdin:
    try:
        line = line.strip()
        pos = komoran.pos(line)
        print(" ".join(["%s|%s" % (p[0], p[1]) for p in pos]))
    except:
        print("error: <", line, ">")
