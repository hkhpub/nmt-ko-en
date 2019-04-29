# -*- coding: utf-8 -*-
# Created by hkh at 2019-02-13

tagfile = open("tst2016.zh-en.tag.en", "r")
tokfile = open("tst2016.zh-en.tok.en", "r")

for i, (tagline, tokline) in enumerate(zip(tagfile.readlines(), tokfile.readlines())):
  w1 = tagline.split(" ")[0].split("|")[0]
  w2 = tokline.split(" ")[0]
  if w1 == w2:
    continue
  else:
    print("line: [%d] %s" % (i, tokline))

tagfile.close()
tokfile.close()