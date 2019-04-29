import sys
import collections
import subword_text_tokenizer

## Usage: python learn_ste.py < corpus.txt > vocab.txt
token_counts = collections.Counter()
for line in sys.stdin:
  token_counts.update(line.strip().split(" "))

target_size=3000
# encoder = subword_text_tokenizer.SubwordTextTokenizer()
# encoder.build_from_token_counts(token_counts, 5, 4)
encoder = subword_text_tokenizer.SubwordTextTokenizer.build_to_target_size(target_size, token_counts, min_val=10, max_val=1e3)
print(encoder.vocab_size)
if len(sys.argv) > 1:
  encoder.store_to_file(sys.argv[1])

