# -*- coding: utf-8 -*-
# Created by hkh at 2019-01-31
import sys

filter_list = ["CC", "IN", "TO", "DT"]

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
        words += ["<mask>" if tag in filter_list else p[0]]
    print(" ".join(words))
  except:
    print("error: <", line, ">")
    print(p)
    exit(0)
