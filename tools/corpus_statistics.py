import argparse
import sys

parser = argparse.ArgumentParser(
    description="Calculate corpus statistics, num of sentences, num of words, average words per sentence.")
parser.add_argument(
    "infile",
    nargs="?",
    type=argparse.FileType("r"),
    default=sys.stdin,
    help="Input tokenized text file to be processed.")
args = parser.parse_args()

num_words = 0
num_sentences = 0
for line in args.infile:
    num_words += len(line.split(" "))
    num_sentences += 1

print("Total sentences: %d" % num_sentences)
print("Total words: %d" % num_words)
print("Average words per sentence: %.2f" % (num_words / num_sentences))


