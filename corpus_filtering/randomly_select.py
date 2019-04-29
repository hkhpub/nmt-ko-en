import argparse
import numpy as np

"""
# Randomly select sentences

python corpus_filtering/randomly_select.py \
--input1=$WMT_DIR/syn.train.tok.clean.ko \
--input2=$WMT_DIR/train.tok.clean.en \
--output1=$WMT_DIR/train.2m.tok.clean.ko \
--output2=$WMT_DIR/train.2m.tok.clean.en \
--size=2000000
"""

np.random.seed(1000)
parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--input1',
    type=str, metavar='FILE', required=True, help='first input file (predicted)')
parser.add_argument(
    '--input2',
    type=str, metavar='FILE', required=True, help='second input file (paired)'
)
parser.add_argument(
    '--output1',
    type=str, metavar='FILE', required=True, help='first output file (predicted)')
parser.add_argument(
    '--output2',
    type=str, metavar='FILE', required=True, help='second output file (paired)')
parser.add_argument(
    '--size',
    type=int, metavar='FILE', required=True, help='maximum length')

args = parser.parse_args()

input1_lines = []
input2_lines = []

input1_file = open(args.input1, "r")
input2_file = open(args.input2, "r")
for line in input1_file.readlines():
    input1_lines += [line.strip()]

for line in input2_file.readlines():
    input2_lines += [line.strip()]

input1_lines = np.asarray(input1_lines)
input2_lines = np.asarray(input2_lines)

selected_indices = np.random.choice(range(len(input1_lines)), size=args.size, replace=False)
sel_input1_lines = input1_lines[selected_indices]
sel_input2_lines = input2_lines[selected_indices]

with open(args.output1, "w") as wf:
    wf.write('\n'.join(sel_input1_lines)+"\n")

with open(args.output2, "w") as wf:
    wf.write('\n'.join(sel_input2_lines)+"\n")
