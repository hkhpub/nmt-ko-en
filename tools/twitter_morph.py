# -*- coding: utf-8 -*-
# Usage: python make_vocab.py < corpus > corpus.vocab
import sys
from konlpy.tag import Twitter
twitter = Twitter()

for line in sys.stdin:
    try:
        line = line.strip()
        print(" ".join(twitter.morphs(line)))
    except:
        print("error: <", line, ">")
