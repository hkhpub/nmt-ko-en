# -*- coding: utf-8 -*-
# Created by hkh at 2019-01-30
import sys
import nltk
from nltk.parse import CoreNLPParser
stanford_dir = '/home/hkh/tools/stanford-postagger-full/'
modelfile = stanford_dir + 'models/chinese-distsim.tagger'
jarfile = stanford_dir + 'stanford-postagger.jar'

# nltk.internals.config_java(options='-Xmx3024m')
# st = StanfordPOSTagger(model_filename=modelfile, path_to_jar=jarfile)
tagger = CoreNLPParser(url='http://localhost:9000', tagtype='pos')

# print(tagger.tag("for all their trouble, I forgive you !".split(" ")))

# lines = ["for all their trouble, I forgive you !".split(" "), "The StanfordTokenizer will be deprecated in version 3.2.5.".split(" ")]

# lines = []
# for line in sys.stdin:
#   line = line.strip()
#   lines += [line.split(" ")]
#   if len(lines) == 2000:
#     pos_sents = tagger.tag_sents(lines)
#     for pos in pos_sents:
#       print(" ".join(["%s|%s" % (p[0], p[1]) for p in pos]))
#     lines = []
# pos_sents = tagger.tag_sents(lines)
# for pos in pos_sents:
#   print(" ".join(["%s|%s" % (p[0], p[1]) for p in pos]))


lines = []
for line in sys.stdin:
  line = line.strip()
  pos_sent = tagger.tag(line.split(" "))
  print(" ".join(["%s|%s" % (p[0], p[1]) for p in pos_sent]), flush=True)

