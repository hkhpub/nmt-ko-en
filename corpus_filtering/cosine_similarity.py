# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-19
import argparse
import numpy as np
from scipy.spatial.distance import cosine
from io import StringIO

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
    type=str, metavar='FILE', required=True, help='first output file (predicted)')

args = parser.parse_args()

source_file = open(args.input1, "r")
target_file = open(args.input2, "r")
output_file = open(args.output, "w")

for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  vec1 = np.loadtxt(StringIO(source))
  vec2 = np.loadtxt(StringIO(target))
  similarity = 1 - cosine(vec1, vec2)
  output_file.write(str(similarity)+"\n")

  if (i+1) % 1000 == 0:
    print(".", end="", flush=True)
  if (i+1) % 10000 == 0:
    print(i+1, end="", flush=True)

# source_vectors = np.loadtxt(source_file)
# print(source_vectors.shape)

# target_vectors = np.loadtxt(target_file)

#
# scores = []
#
# print(len(scores))
# scores = np.asarray(scores)
# # ids = np.asarray(scores).argsort()      # ascending order
# ids = np.asarray(scores).argsort()[::-1]  # descending order
# print(scores[ids[:100]])
#
# sent_pairs = []
# for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
#   sent_pairs += [(source, target)]
# sent_pairs = np.asarray(sent_pairs)
# # for pair in sent_pairs[ids[:100]]:
# #   print(pair[0])
# #   print(pair[1])
#
# output1_file = open(args.output1, "w")
# output2_file = open(args.output2, "w")
#
# for pair in sent_pairs[ids]:
#   output1_file.write(pair[0])
#   output2_file.write(pair[1])
