# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-19
import argparse
import numpy as np
import math

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--input1',
    type=str, metavar='FILE', required=True, help='first input file (paired)')
parser.add_argument(
    '--input2',
    type=str, metavar='FILE', required=True, help='second input file (paired)'
)
parser.add_argument(
    '--output1',
    type=str, metavar='FILE', required=True, help='first output file (paired)')
parser.add_argument(
    '--output2',
    type=str, metavar='FILE', required=True, help='second output file (paired)')
parser.add_argument(
    '--trash',
    type=str, metavar='FILE', required=True, help='Trash sentence output')
# parser.add_argument(
#     '--output',
#     type=str, metavar='FILE', required=True, help='filtered lines output file'
# )

args = parser.parse_args()

source_file = open(args.input1, "r")
target_file = open(args.input2, "r")

output1_file = open(args.output1, "w")
output2_file = open(args.output2, "w")
trash_file = open(args.trash, "w")

proper_chars = "다요죠"
proper_periods = "?!."
for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  word_seqs = target.strip().split(" ")
  last_char = word_seqs[-1][-1]
  try:
    if last_char in proper_periods and word_seqs[-2][-1] not in proper_chars:
      trash_file.write(target)
    elif last_char not in proper_periods and last_char not in proper_chars:
      trash_file.write(target)
    elif last_char not in proper_periods:
      output1_file.write(source)
      output2_file.write(target.strip()+".\n")
    else:
      output1_file.write(source)
      output2_file.write(target)

    if (i+1) % 1000 == 0:
      print(".", end="", flush=True)
    if (i+1) % 10000 == 0:
      print(i+1, end="", flush=True)
  except:
    print("exception: ", i, source, target)
