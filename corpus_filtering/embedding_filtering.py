# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-18
from gensim.models import KeyedVectors
from gensim.test.utils import datapath
import argparse
import numpy as np
import scipy

KO_EMB_VEC = "/home/hkh/data/wikipedia_dumps/biling-word2vec/kowiki_mapped_sup.vec"
EN_EMB_VEC = "/home/hkh/data/wikipedia_dumps/biling-word2vec/enwiki_mapped_sup.vec"
ko_emb = KeyedVectors.load_word2vec_format(datapath(KO_EMB_VEC), binary=False)
print("ko_emb Loaded")
en_emb = KeyedVectors.load_word2vec_format(datapath(EN_EMB_VEC), binary=False)
print("en_emb Loaded")

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--input1',
    type=str, metavar='FILE', required=True, help='first input file (predicted)')
parser.add_argument(
    '--input2',
    type=str, metavar='FILE', required=True, help='second input file (paired)'
)
parser.add_argument(
    '--output',
    type=str, metavar='FILE', required=True, help='filtered lines output file'
)
args = parser.parse_args()

source_file = open(args.input1, "r")
target_file = open(args.input2, "r")
output_file = open(args.output, "w")


def calc_sent_emb(sentence, emb):
  """
  :param sentence: sequence of words in string
  :return:
  """
  vecs = []
  for w in sentence.split(" "):
    if w not in emb:
      continue
    vecs += [emb.word_vec(w)]
  vecs = np.asarray(vecs)
  return vecs.mean(axis=0)


for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  if (i+1) % 1000 == 0:
    print(".", end="", flush=True)
  if (i+1) % 10000 == 0:
    print(i+1, end="", flush=True)

  src_emb = calc_sent_emb(source, en_emb)
  tgt_emb = calc_sent_emb(target, ko_emb)
  similarity = 1 - scipy.spatial.distance.cosine(src_emb, tgt_emb)
  output_file.write(str(similarity) + "\n")
