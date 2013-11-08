#!/usr/bin/env python

import sys

current_word = None
current_count = 0
word = None
for line in sys.stdin:
    line = line.strip()
    line = line.split()
    word = line[0:4]
    count = line[4]
    try:
        count = int(count)
    except ValueError:
        continue
    if current_word == word:
        current_count += count
    else:
        if current_word:
            # write result to STDOUT
            print '%s\t%s' % (current_word, current_count)
        current_count = count
        current_word = word
if current_word == word:
    print '%s\t%s' % (current_word, current_count)

