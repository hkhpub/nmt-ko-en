# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-12
import sys
for line in sys.stdin:
  tokens = line.strip().split(" ")
  tokens = [tok+'_' for tok in tokens[:-1]] + [tokens[-1]]   # leave rear word as is
  line = " ".join(tokens)
  print(line)
