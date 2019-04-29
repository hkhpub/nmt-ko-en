import sys
import subword_text_tokenizer

## Usage: python encode_ste.py < train.txt > train.ste.txt

if len(sys.argv) != 2:
  raise RuntimeError("SubwordTextTokenizer vocab file's not found")
encoder = subword_text_tokenizer.SubwordTextTokenizer(sys.argv[1])

for line in sys.stdin:
  print(line.strip())
  print(" ".join(encoder.encode(line.strip())))
  print()

