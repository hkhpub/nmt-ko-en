# -*- coding: utf-8 -*-
# Created by hkh at 2019-01-29
import sys
from konlpy.tag import Komoran
komoran = Komoran()

for line in sys.stdin:
    try:
        line = line.strip()
        pos = [w.split("|") for w in line.split(" ")]
        words = []
        for p in pos:
          if len(p) != 2:
            words += [p[0]]
          else:
            tag = p[1]
            words += ["<josa>" if tag[0] == 'J' else p[0]]
        print(" ".join(words))
    except:
        print("error: <", line, ">")
        print(p)
        exit(0)
