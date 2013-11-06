__author__ = 'EliotP'

import csv

#ofile = csv.writer(open("TESTING.csv","wb"))
writer = csv.writer(ofile, delimeter='\t')

current_word = None
current_count = 0
word = None
for line in sys.stdin:
    line = line.strip()
    word, count = line.split('\t',1)
    try:
        count = int(count)
    except ValueError:
        continue
    if current_word == word:
        current_count += count
    else:
        if current_word:
            # write result to STDOUT
            writer.writerow(current_word, current_count)
            #print '%s\t%s' % (current_word, current_count)
        current_count = count
        current_word = word
if current_word == word:
    writer.writerow(current_word, current_count)
    #print '%s\t%s' % (current_word, current_count)

#current_word = None
#current_count = 0
#word = None
#for line in sys.stdin:
#    line = line.strip()
#    word, count = line.split('\t',1)
#    try:
#        count = int(count)
#    except ValueError:
#        continue
#    if current_word == word:
#        current_count += count
#    else:
#        if current_word:
#            # write result to STDOUT
#            print '%s\t%s' % (current_word, current_count)
#        current_count = count
#        current_word = word
#if current_word == word:
#    print '%s\t%s' % (current_word, current_count)