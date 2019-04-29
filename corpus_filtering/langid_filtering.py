# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-18
import argparse
import langid

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

for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  if (i+1) % 1000 == 0:
    print(".", end="", flush=True)
  if (i+1) % 10000 == 0:
    print(i+1, end="", flush=True)
  src_langid = langid.classify(source)
  tgt_langid = langid.classify(target)
  if src_langid[0] == "en" and tgt_langid[0] == "ko":
    output_file.write(str(1) + "\n")
  else:
    output_file.write(str(0)+"\n")
    output_file.flush()
    # print(src_langid, tgt_langid)
# print("\n".join(filtered_lines))
